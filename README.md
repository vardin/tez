## MapReduce Job
mapred-site.xml  
```xml
<configuration>
  <property>
    <name>mapreduce.framework.name</name>
    <value>yarn</value>
  </property>
<configuration>
```
```
$HADOOP_PREFIX/bin/hadoop jar $HADOOP_PREFIX/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.3.jar grep input output 'dfs[a-z.]+'
```

## TEX Job
mapred-site.xml  
```xml
<configuration>
  <property>
    <name>mapreduce.framework.name</name>
    <value>yarn-tez</value>
  </property>
<configuration>
```

```
$HADOOP_PREFIX/bin/hadoop jar ${TEZ_HOME}/tez-examples-0.7.1.jar orderedwordcount input output-owc
```
