function new-psobjectfrommatches {
#requires -version 2.0
<#
.SYNOPSIS
Creates a PS object from the groups created by the .match() method of [regex]
.DESCRIPTION
Accepts an array of strings ([string[]]) as pipeline input
 and creates custom PS objects from them,
 based on a regular express and list of property names given as parameter arguments.
 
.PARAMETER Pattern
Regular expression used to match and group data for the object properties.
The expression must include capturing groups (designated by parens)
 for each property you wish to capture data for.
 
.PARAMETER Property
Array of  property names for the output objets. 
The names must appear in the same order as the capture groups are enumerated.  
Use $nul as a place holder for any groups that are captured
 but that you do not want included as properties of the output objects.
The base match (group[0]) is included, and will be the first group processed. 
.EXAMPLE
PS C:\> "bill.gates@microsoft.com" | new-psobjectfrommatches  -pattern "(\w+)@(\w+\.\w+) -property $nul,UserName,Domain
Parses the email address and creates a PS custom object
  with properties of UserName and Domain from the regular expression capture groups.
  
.EXAMPLE
PS C:\> net view | new-psobjectfrommatches -pat "\\\\(\S+)\s+(.+)$" -prop $nul,ComputerName,Description
Parses the output form the net view command and creates an array of ps objects 
	with ComputerName and Decription properties.
	
.EXAMPLE
PS C:\>netstat | new-psobjectfrommatches -pattern "(TCP|UDP)\s+(\S+)\s+(\S+)\s+(\S+)" -property $nul,Protocol,LocalAddress,ForeignAddress,State 
Parses the output form the netstat command and creates an array of ps objects 
	with Protocol, LocalAddress, ForeignAddress, and State properties
	
.NOTES
NAME        :  new-psobjectfrommatches
VERSION     :  1.0.0   
LAST UPDATED:  4/14/2011
AUTHOR      :  Rob Campbell
.LINK
http://msdn.microsoft.com/en-us/library/hs600312.aspx 
http://regexlib.com/CheatSheet.aspx
.INPUTS
Takes a single string or an array of strings as pipeline input.
.OUTPUTS
Outputs one custom PS object per match found in the input data.
#>
param
    (
	[Parameter(Mandatory=${t`RUE}, valuefrompipeline=${tR`uE})]
	[AllowEmptyString()]
	[string[]]
    ${M`A`TCHd`AtA},
    
    [Parameter(Mandatory=${Tr`uE})]
    [regex]
    ${P`AT`TErN},
    
    [Parameter(Mandatory=${TR`ue})]
    [AllowEmptyString()]
    [string[]]
    ${proP`E`RTy}
    )
     
begin{
write-debug "Match regex is $($pattern.tostring())"
${proPer`T`Y_cou`Nt} = ${pR`O`perty}.count
}
process{
#Read data and match to pattern
${Mat`CH`esF`o`unD} = ${pa`T`Tern}.matches(${MAtCH`d`Ata})
#get number of captures (used in foreach-object loop later)
${Ca`ptURe_`Co`UNT} = ${mA`TChe`sfo`u`ND}[0].groups.count
write-debug "Pattern produced $capture_count captures."
write-debug "Property count is $($property.count)"      
Write-Debug "Found $($matchesfound.count) matches in input data"
 
foreach (${mAt`CHF`Ou`ND} in ${maTcHES`F`oUND}){
	Write-Debug "Matched string $($matchfound.groups[0].value) at index $($matchfound.index)"
	
	#create an new PS object to return
	${M`AtChE`DD`AtA`_oBjECT} = new-object -TypeName psobject
	
	#For each capture group, see if $property array has a property name at the same index
	#If property names exists for that group index, add a noteproperty the object
	#Set the value of the property to the value of the match group with the same index
	
	0..(${cap`TURe_`c`OuNT} - 1) | foreach-object {
	
		write-debug "Processing group $_ `n Value of group $_ is $($matchfound.groups["$_"])"
			
        if (${PRO`pe`RTY}[${_}]){		    
			write-debug "Found property name $($property[$_]) for group $_  - Adding property"
		    ${mATcH`ED`dAt`A_Ob`je`ct} | add-member -MemberType noteproperty -name $(${PrOpe`R`Ty}[${_}]) -value $(${M`At`c`HfoUnD}.groups["$_"].value)
            }
			
       else {
	   		write-debug "Property name not found for group $_ - not added"
            } 
         }
		 
		 #return the object
		 Write-Debug "Finished processing captures for this match. Outputting object"
	     write-output ${ma`TChEDDATa_ObJ`E`CT}
}
}
}

