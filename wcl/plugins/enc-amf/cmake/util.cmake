Function(CacheSet Name Value)
	GET_PROPERTY(V_ADVANCED CACHE "${Name}" PROPERTY ADVANCED)
	GET_PROPERTY(V_TYPE CACHE "${Name}" PROPERTY TYPE)
	GET_PROPERTY(V_HELPSTRING CACHE "${Name}" PROPERTY HELPSTRING)
	Set(${Name} ${Value} CACHE ${V_TYPE} ${V_HELPSTRING} FORCE)
	If(${V_ADVANCED})
		Mark_As_Advanced(FORCE ${Name})
	EndIf()
EndFunction()

Function(CacheClear Name)
	GET_PROPERTY(V_ADVANCED CACHE "${Name}" PROPERTY ADVANCED)
	GET_PROPERTY(V_TYPE CACHE "${Name}" PROPERTY TYPE)
	GET_PROPERTY(V_HELPSTRING CACHE "${Name}" PROPERTY HELPSTRING)
	Set(${Name} 0 CACHE ${V_TYPE} ${V_HELPSTRING} FORCE)
	If(${V_ADVANCED})
		Mark_As_Advanced(FORCE ${Name})
	EndIf()	
EndFunction()