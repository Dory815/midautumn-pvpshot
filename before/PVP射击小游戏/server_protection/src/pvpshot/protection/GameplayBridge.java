package pvpshot.protection;

import java.net.URLClassLoader;
import java.nio.file.Path;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;

/** Bootstrap-visible bridge into the official server's isolated game loader. */
public final class GameplayBridge {
    private static final Map<ClassLoader,Map<String,Method>> methods=new HashMap<>();
    public static boolean call(String name,Object object,Object argument) {
        try {
            var loader=object.getClass().getClassLoader();
            var table=methods.get(loader);
            if(table==null){
                var child=new URLClassLoader(new java.net.URL[]{Path.of(System.getProperty("pvpshot.gameplay.jar")).toUri().toURL()},loader);
                var implementation=Class.forName("pvpshot.gameplay.GameplayRules",true,child);
                table=new HashMap<>();
                for(var m:implementation.getMethods())if(m.getParameterCount()==2)table.put(m.getName(),m);
                methods.put(loader,table);
            }
            return (boolean)table.get(name).invoke(null,object,argument);
        }catch(Throwable error){throw new IllegalStateException("PVP gameplay hook failed: "+name,error);}
    }
}
