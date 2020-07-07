Class User.MedicalAppointments Extends %Persistent
{

Property Especialidad As %Integer;

Property Edad As %Integer;

Property Sexo As %Integer(DISPLAYLIST = ",Male,Female", VALUELIST = ",1,2");

Property ReservaMesD As %Integer;

Property ReservaDiaD As %Integer;

Property ReservaHoraD As %Integer;

Property CreacionMesD As %Integer;

Property CreacionDiaD As %Integer;

Property CreacionHoraD As %Integer;

Property Latencia As %Integer;

Property Canal As %Integer(DISPLAYLIST = ",Call center,Personal,Web", VALUELIST = ",1,2,3");

Property Tipo As %Integer(DISPLAYLIST = ",Medical,Procedure", VALUELIST = ",1,2");

Property Show As %Boolean;

Storage Default
{
<Data name="MedicalAppointmentsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Especialidad</Value>
</Value>
<Value name="3">
<Value>Edad</Value>
</Value>
<Value name="4">
<Value>Sexo</Value>
</Value>
<Value name="5">
<Value>ReservaMesD</Value>
</Value>
<Value name="6">
<Value>ReservaMesC</Value>
</Value>
<Value name="7">
<Value>ReservaDiaD</Value>
</Value>
<Value name="8">
<Value>ReservaDiaC</Value>
</Value>
<Value name="9">
<Value>ReservaHoraD</Value>
</Value>
<Value name="10">
<Value>ReservaHoraC</Value>
</Value>
<Value name="11">
<Value>CreacionMesD</Value>
</Value>
<Value name="12">
<Value>CreacionMesC</Value>
</Value>
<Value name="13">
<Value>CreacionDiaD</Value>
</Value>
<Value name="14">
<Value>CreacionDiaC</Value>
</Value>
<Value name="15">
<Value>CreacionHoraD</Value>
</Value>
<Value name="16">
<Value>CreacionHoraC</Value>
</Value>
<Value name="17">
<Value>Latencia</Value>
</Value>
<Value name="18">
<Value>Canal</Value>
</Value>
<Value name="19">
<Value>Tipo</Value>
</Value>
<Value name="20">
<Value>Show</Value>
</Value>
</Data>
<DataLocation>^User.MedicalAppointmentsD</DataLocation>
<DefaultData>MedicalAppointmentsDefaultData</DefaultData>
<IdLocation>^User.MedicalAppointmentsD</IdLocation>
<IndexLocation>^User.MedicalAppointmentsI</IndexLocation>
<StreamLocation>^User.MedicalAppointmentsS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
