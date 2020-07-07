Class MyMetric.Freespace Extends %Monitor.Adaptor
{

Parameter INDEX = "DBName";

/// Name of dataset (OK)
Property DBName As %Monitor.String;

/// Current amount of Freespace (BLZ)
Property FreeSpace As %Monitor.String;

/// Result Set
Property Rspec As %SQL.StatementResult [ Internal ];

/// Initialize the list of datasets and freespace.
Method Initialize() As %Status
{
	/*zn "%SYS"
    set stmt=##class(%SQL.Statement).%New()
    set status= stmt.%PrepareClassQuery("SYS.Database","FreeSpace")
    set ..Rspec = stmt.%Execute()
    zn "USER"*/
    set ^j("flag") = 0
    return $$$OK
}

/// Get routine metric sample. 
/// A return code of $$$OK indicates there is a new sample instance. 
/// Any other return code indicates there is no sample instance. 
Method GetSample() As %Status
{
	/*
    // Get freespace data
    set stat = ..Rspec.%Next(.sc)

    // Quit if we have done all the datasets
    if 'stat {
        Quit 0
    }

    // populate this instance
    set ..DBName = ..Rspec.%Get("Directory")_"_ok"
    set ..FreeSpace = "**"_..Rspec.%Get("Available")

    // quit with return value indicating the sample data is ready
    return $$$OK
    */
    
    set ..DBName = "_ok"
    set ..FreeSpace = "#"_$G(^j("count"), 0)
    set ^j("count") = $G(^j("count"), 0) + 1
    return:$G(^j("flag")) 0
    set ^j("flag") = 1
    return $$$OK
}

}
