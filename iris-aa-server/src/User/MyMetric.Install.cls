Class MyMetric.Install Extends %RegisteredObject
{

Property LocalClassName As %String;

ClassMethod Install(
	pClassName As %String,
	pSourceCodeLocal As %String)
{
	Do START^%SYSMONMGR
	Do RegSysClass^%MONAPPMGR
	
	Do $SYSTEM.OBJ.Load(pSourceCodeLocal, "ck")
	Set inst = ..%New()
	Set inst.LocalClassName = pClassName
	Do inst.RegisterMe()
	
	Do inst.RestartMonitor()
}

ClassMethod Uninstall(pClassName As %String)
{
	Set inst = ..%New()
	Set inst.LocalClassName = pClassName
	Do inst.UnRegisterMe()
	Do $SYSTEM.OBJ.Delete(pClassName)
	Do inst.RestartMonitor()
}

Method RestartMonitor()
{
	Do STOP^%SYSMONMGR
	Hang 5
	Do START^%SYSMONMGR
}

Method RegisterMe()
{
	s Classname=..LocalClassName
	Do $SYSTEM.OBJ.Compile(Classname)
	s id=""
	d ##class(%Monitor.ItemGroup).MetricsClassItemGroup(Classname,.id)
	s class=##class(%Monitor.ItemGroup).%OpenId(id)
	i '$IsObject(class) w !,"ERROR: Class '"_Classname_"' does not exist",! goto End
	i 'class.Activated s class.Activated = 1
	s status = class.%Save()
	If ('status) Do DecomposeStatus^%apiOBJ(status,.err,"-d") For i=1:1:err Write err(i),!
	k class
	q
 
End
}

Method UnRegisterMe()
{
	s Classname=..LocalClassName
	s id=""
	d ##class(%Monitor.ItemGroup).MetricsClassItemGroup(Classname,.id)
	i id="" w !,"ERROR: Class '"_Classname_"' does not exist",! goto End
	s status=##class(%Monitor.ItemGroup).%DeleteId(id)
	If ('status) Do DecomposeStatus^%apiOBJ(status,.err,"-d") For i=1:1:err Write err(i),!
	s sc=##class(%Monitor.Manager).Purge(Classname)
	i sc'=1 w !,"Error: "_sc,!
	q

End
}

ClassMethod Test(pClassName As %String)
{
	set mclass=pClassName
	set col=##class(%Monitor.SampleAgent).%New(mclass)
	write col.Collect()
	write ##class(%Monitor.View).Display(mclass)
}

}
