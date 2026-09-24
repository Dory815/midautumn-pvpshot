package pvpshot.protection;

import java.lang.reflect.*;
import java.nio.file.*;
import java.util.*;

/** Reflection keeps the agent compatible with the official bundler's isolated class loader. */
public final class ProtectionRules {
    record Region(int x0,int y0,int z0,int x1,int y1,int z1) {
        boolean contains(int x,int y,int z) { return x>=x0&&x<=x1&&y>=y0&&y<=y1&&z>=z0&&z<=z1; }
    }
    static final Map<Long,List<Region>> chunks = new HashMap<>();
    static long chunkKey(int x,int z) { return ((long)(x>>4)<<32) ^ ((z>>4)&0xffffffffL); }
    public static void load(Path file) throws Exception {
        int count=0;
        for (String line:Files.readAllLines(file)) {
            if (line.isBlank()||line.startsWith("#")) continue;
            String[] fields=line.split("\\s+");
            if(fields.length<7) throw new IllegalArgumentException("Invalid protection region: "+line);
            Region r=new Region(Integer.parseInt(fields[0]),Integer.parseInt(fields[1]),Integer.parseInt(fields[2]),
                Integer.parseInt(fields[3]),Integer.parseInt(fields[4]),Integer.parseInt(fields[5]));
            if(r.x0>r.x1||r.y0>r.y1||r.z0>r.z1)throw new IllegalArgumentException("Inverted region: "+line);
            for(int x=r.x0>>4;x<=r.x1>>4;x++)for(int z=r.z0>>4;z<=r.z1>>4;z++)
                chunks.computeIfAbsent(chunkKey(x<<4,z<<4), k->new ArrayList<>()).add(r);
            count++;
        }
        if(count==0)throw new IllegalArgumentException("Empty protection region file");
        System.out.println("[PVP Protection] Loaded "+count+" regions in "+chunks.size()+" chunk buckets.");
    }
    record PositionAccess(Method x,Method y,Method z) {
        PositionAccess(Class<?> c) throws Exception {this(c.getMethod("getX"),c.getMethod("getY"),c.getMethod("getZ"));}
    }
    static final ClassValue<PositionAccess> positions=new ClassValue<>() {
        protected PositionAccess computeValue(Class<?> c) {try{return new PositionAccess(c);}catch(Exception e){throw new IllegalStateException(e);}}
    };
    static final class LevelAccess {
        final Method dimension,identifier,scoreboard,objective,score,value,state,block;
        final Object active,edit,reset;
        LevelAccess(Class<?> c) throws Exception {
            ClassLoader loader=c.getClassLoader();
            Class<?> holder=loader.loadClass("net.minecraft.world.scores.ScoreHolder");
            Class<?> obj=loader.loadClass("net.minecraft.world.scores.Objective");
            Class<?> info=loader.loadClass("net.minecraft.world.scores.ReadOnlyScoreInfo");
            dimension=c.getMethod("dimension"); identifier=dimension.getReturnType().getMethod("identifier");
            scoreboard=c.getMethod("getScoreboard");
            objective=scoreboard.getReturnType().getMethod("getObjective",String.class);
            score=scoreboard.getReturnType().getMethod("getPlayerScoreInfo",holder,obj);
            value=info.getMethod("value");
            state=c.getMethod("getBlockState",loader.loadClass("net.minecraft.core.BlockPos"));
            block=state.getReturnType().getMethod("getBlock");
            Method named=holder.getMethod("forNameOnly",String.class);
            active=named.invoke(null,"#protection.active"); edit=named.invoke(null,"#protection.edit"); reset=named.invoke(null,"#reset.active");
        }
        int read(Object board,Object objective,Object name) throws Exception {
            Object entry=score.invoke(board,name,objective);
            return entry==null?0:(int)value.invoke(entry);
        }
        boolean enabled(Object level) throws Exception {
            if(!identifier.invoke(dimension.invoke(level)).toString().equals("minecraft:overworld"))return false;
            Object board=scoreboard.invoke(level),clock=objective.invoke(board,"ustc.clock");
            return clock!=null && read(board,clock,active)==1 && read(board,clock,edit)!=1 && read(board,clock,reset)!=1;
        }
    }
    static final ClassValue<LevelAccess> levels=new ClassValue<>() {
        protected LevelAccess computeValue(Class<?> c) {try{return new LevelAccess(c);}catch(Exception e){throw new IllegalStateException(e);}}
    };
    public static boolean protectedAt(Object level,Object pos) {
        try {
            var p=positions.get(pos.getClass());int x=(int)p.x.invoke(pos),y=(int)p.y.invoke(pos),z=(int)p.z.invoke(pos);
            var nearby=chunks.get(chunkKey(x,z));
            if(nearby==null)return false;
            for(var region:nearby)if(region.contains(x,y,z))return levels.get(level.getClass()).enabled(level);
            return false;
        } catch(Throwable failure) {throw new IllegalStateException("Facility protection check failed",failure);}
    }
    public static boolean denySet(Object level,Object pos,Object replacement) {
        if(!protectedAt(level,pos))return false;
        try {
            var access=levels.get(level.getClass());
            // Buttons, chest lids/redstone and doors must still update their block properties.
            return access.block.invoke(access.state.invoke(level,pos)) != access.block.invoke(replacement);
        } catch(Exception failure) {throw new IllegalStateException("Facility block update check failed",failure);}
    }
}
