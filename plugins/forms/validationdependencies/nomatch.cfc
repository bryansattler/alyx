<cfcomponent output="no" extends="_common">

	<cffunction name="validate" output="no">
		<cfargument name="form"       required="yes"/>
		<cfargument name="params"     required="yes"/>

		<cfset var local = StructNew()/>
		<cfset local.fields = ListToArray(arguments.params.fields)/>
		<cfset local.refFieldValue = arguments.form.getFieldValue(local.fields[1])/>
		<cfset local.fieldLabels = arguments.form.getField(local.fields[1]).label/>
		<cfset local.matches = false/>
		<cfset local.numFields = ArrayLen(local.fields)/>

		<cfloop from="1" to="#local.numFields#" index="local.fieldIndex">
			<cfset local.field = arguments.form.getField(local.fields[local.fieldIndex])/>

			<cfif ArrayLen(local.field.errors)>
				<!--- Skip dependency checking if any fields already have an error --->
				<cfset local.matches = false/>
				<cfbreak/>
			</cfif>

			<cfset local.fieldValue = arguments.form.getFieldValue(local.field.name)/>

			<cfif local.fieldIndex eq 1>
				<cfset local.fieldLabels = local.field.label/>
				<cfset local.refFieldValue = local.fieldValue/>
			<cfelse>
				<cfif local.fieldIndex lt local.numFields>
					<cfset local.fieldLabels &= ", " & local.field.label/>
				<cfelse>
					<cfset local.fieldLabels &= " and " & local.field.label/>
				</cfif>

				<cfif getIgnoreCase()>
					<cfset local.matchResults = CompareNoCase(local.fieldValue, local.refFieldValue)/>
				<cfelse>
					<cfset local.matchResults = Compare(local.fieldValue, local.refFieldValue)/>
				</cfif>

				<cfif local.matchResults eq 0>
					<cfset local.matches = true/>
					<cfbreak/>
				</cfif>
			</cfif>
		</cfloop>

		<cfif local.matches>
			<cfset local.errorMsg = getErrorMessage("mustnotmatch", arguments.params.errorMsg)/>
			<cfset local.errorMsg = Replace(local.errorMsg, "%%fieldname%%", local.fieldLabels)/>
			<cfset arguments.form.addError(local.errorMsg, local.fields)/>
		</cfif>
	</cffunction>

	<cffunction name="getIgnoreCase" access="private" output="no">
		<cfreturn false/>
	</cffunction>

	<!--- -------------------- Client Side Validation -------------------- --->

	<cffunction name="getClientSideValidationScript" output="no">
		<cfargument name="form"    required="yes"/>
		<cfargument name="params"  required="yes"/>
		<cfargument name="context" required="yes"/>

		<cfset var local = StructNew()/>
		<cfset local.fields = ListToArray(arguments.params.fields)/>
		<cfset local.fieldLabels = getFieldLabels(arguments.form, local.fields)/>

		<cfif not StructKeyExists(arguments.context.validationHelpers, "noMatch")>
			<cfset arguments.context.validationHelpers.noMatch = "function validateNoMatch(form,fields,errorMsg){fields=fields.split(',');var ref=form.getValue(fields[0]);if(!ref.length)return;for(var i=1;i<fields.length;++i){if(form.getValue(fields[i])==ref){form.addErrorMessages(errorMsg,fields);break;}}}"/>
		</cfif>

		<cfset local.errorMsg = getErrorMessage("mustnotmatch", arguments.params.errorMsg)/>
		<cfset local.errorMsg = Replace(local.errorMsg, "%%fieldname%%", local.fieldLabels)/>
		<cfset arguments.context.output.append("validateNoMatch(this,'" & arguments.params.fields & "','" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');")/>
	</cffunction>

</cfcomponent>