/**
 * @author Andrei Kakhanouski <akohan91@gmail.com>
 */
public with sharing class libak_DynamicSOQL {
	private ISobjectFieldPathConstructable fieldPathConstructor;
	private String sObjectName;
	private List<libak_DynamicSOQLFunction> selectFunctions = new List<libak_DynamicSOQLFunction>();
	private List<String> selectFields = new List<String>();
	private Map<String, libak_DynamicSOQL> subQueries = new Map<String, libak_DynamicSOQL>();
	private libak_DynamicSOQLConditionBlock conditionBlock;
	private libak_DynamicSOQLGroupBy groupBy;
	private libak_DynamicSOQLOrderBy orderBy;
	private Integer offsetNumber;
	private Integer limitNumber;

	/**
	 * The Factory class is responsible for constructing instances of the libak_DynamicSOQL class.
	 */
	public class Factory {
		ISobjectFieldPathConstructable fieldPathConstructor;

		/**
		 * Constructor for the Factory class.
		 *
		 * @param fieldPathConstructor an instance of ISobjectFieldPathConstructable used to construct field paths.
		 */
		public Factory(ISobjectFieldPathConstructable fieldPathConstructor) {
			this.fieldPathConstructor = fieldPathConstructor;
		}

		/**
		 * Builds a libak_DynamicSOQL instance from a JSON string.
		 *
		 * @param dynamicSOQLjson the JSON string representing a libak_DynamicSOQL object.
		 * @return a new instance of libak_DynamicSOQL.
		 */
		public libak_DynamicSOQL build(String dynamicSOQLjson) {
			libak_DynamicSOQL instance = (libak_DynamicSOQL)JSON.deserialize(dynamicSOQLjson, libak_DynamicSOQL.class);
			return instance.withFieldPathConstructor(this.fieldPathConstructor);
		}

		/**
		 * Builds a libak_DynamicSOQL instance for the specified SObject type.
		 *
		 * @param sObjectType the SObject type for which the libak_DynamicSOQL is to be built.
		 * @return a new instance of libak_DynamicSOQL.
		 */
		public libak_DynamicSOQL build(SObjectType sObjectType) {
			return new libak_DynamicSOQL(sObjectType.getDescribe().getName())
				.withFieldPathConstructor(this.fieldPathConstructor);
		}
	}

	/**
	 * @author Andrei Kakhanouski <akohan91@gmail.com>
	 * The ISobjectFieldPath interface defines a method for retrieving the field description of a target field.
	 */
	public interface ISobjectFieldPath {
		
		/**
		 * Returns the DescribeFieldResult for a target field.
		 * @return the DescribeFieldResult for the target field.
		 */
		Schema.DescribeFieldResult targetFieldDescribe();
	}

	/**
	 * @author Andrei Kakhanouski <akohan91@gmail.com>
	 * The ISobjectFieldPathConstructable interface defines a method for constructing field paths for SObjects.
	 */
	public interface ISobjectFieldPathConstructable {
		
		/**
		 * Constructs an ISobjectFieldPath based on the provided SObject API name and field path.
		 *
		 * @param sobjectApiName the API name of the SObject.
		 * @param fieldPath the path of the field within the SObject.
		 * @return an instance of ISobjectFieldPath representing the constructed field path.
		 */
		ISobjectFieldPath construct(String sobjectApiName, String fieldPath);
	}

	// CONSTRUCTORS

	/**
	 * @param  sObjectName { String } - API name of sObject
	 * @return             { libak_DynamicSOQL }
	 */
	public libak_DynamicSOQL(String sObjectName) {
		this.sObjectName = sObjectName;
	}

	/* PUBLIC METHODS */

	/**
	 * Sets the field path constructor for this libak_DynamicSOQL instance.
	 *
	 * @param fieldPathConstructor an instance of ISobjectFieldPathConstructable used to construct field paths.
	 * @return the current instance of libak_DynamicSOQL with the updated field path constructor.
	 */
	public libak_DynamicSOQL withFieldPathConstructor(ISobjectFieldPathConstructable fieldPathConstructor) {
		if (this.fieldPathConstructor == null) {
			this.fieldPathConstructor = fieldPathConstructor;
		}
		return this;
	}

	/**
	 * @description Adds a field to SELECT statement
	 * @param  fieldName { String } - API field name
	 * @return           { libak_DynamicSOQL }
	 */
	public libak_DynamicSOQL withField(String fieldName) {
		this.selectFields.add(fieldName);
		return this;
	}

	/**
	 * @description Adds a function to SELECT statement like "COUNT(Id) recordsCount"
	 * @param  function { libak_DynamicSOQLFunction }
	 * @return          { libak_DynamicSOQL }
	 */
	public libak_DynamicSOQL withFunction(libak_DynamicSOQLFunction function) {
		this.selectFunctions.add(function);
		return this;
	}

	/**
	 * @description Adds a subquery
	 * @param  relationshipName { String } - relationship api name of sObject
	 * @param  subQuery         { libak_DynamicSOQL } - libak_DynamicSOQL instance
	 * @return                  { libak_DynamicSOQL }
	 */
	public libak_DynamicSOQL withSubQuery(String relationshipName, libak_DynamicSOQL subQuery) {
		this.subQueries.put(relationshipName, subQuery.withFieldPathConstructor(this.fieldPathConstructor));
		return this;
	}

	/**
	 * @description Adds a condition block to the query
	 * @param  conditionBlock { libak_DynamicSOQLConditionBlock }
	 * @return                { libak_DynamicSOQL }
	 */
	public libak_DynamicSOQL withConditions(libak_DynamicSOQLConditionBlock conditionBlock) {
		this.conditionBlock = conditionBlock;
		return this;
	}

	/**
	 * @description Adds a GROUP BY statement to the query
	 * @param  groupBy { libak_DynamicSOQLGroupBy }
	 * @return         { libak_DynamicSOQL }
	 */
	public libak_DynamicSOQL withGroupBy(libak_DynamicSOQLGroupBy groupBy) {
		this.groupBy = groupBy;
		return this;
	}

	/**
	 * @description Adds a ORDER BY statement to the query
	 * @param  orderBy orderBy description
	 * @return         return description
	 */
	public libak_DynamicSOQL withOrderBy(libak_DynamicSOQLOrderBy orderBy) {
		this.orderBy = orderBy;
		return this;
	}

	/**
	 * @description Adds OFFSET statement to SOQL
	 * @param  offsetNumber { Integer }
	 * @return              { libak_DynamicSOQL }
	 */
	public libak_DynamicSOQL withOffset(Integer offsetNumber) {
		this.offsetNumber = offsetNumber;
		return this;
	}

	/**
	 * @description Adds LIMIT statement to SOQL
	 * @param  limitNumber { Integer }
	 * @return             { libak_DynamicSOQL }
	 */
	public libak_DynamicSOQL withLimit(Integer limitNumber) {
		this.limitNumber = limitNumber;
		return this;
	}

	/**
	 * @description Returns the Map in format: sObjectApiName => Set<String>{fieldApiName}
	 * @return   { Map<String, Set<String>> }
	 */
	public Map<String, Set<String>> infoToFLSCheck() {
		Map<String, Set<String>> result = new Map<String, Set<String>>();
		result.put(this.sObjectName, new Set<String>(this.selectFields));
		result = this.addFunctionFieldsToFlsMap(result);
		result = this.addSubQueryFieldsToFlsMap(result);
		if (this.conditionBlock != null) {
			result.get(this.sObjectName).addAll(this.conditionBlock.fieldsApiNames());
		}
		if (this.orderBy != null) {
			result.get(this.sObjectName).addAll(this.orderBy.fieldsApiNames());
		}
		return result;
	}

	/**
	 * @description Builds a SOQL string
	 * @return   { String }
	 */
	public String stringify() {
		this.sObjectName = String.escapeSingleQuotes(this.sObjectName);
		DescribeSObjectResult sObjectDescription = libak_DynamicSOQLConstants.GLOBAL_DESCRIBE.get(this.sObjectName)?.getDescribe();
		if (sObjectDescription == null) {
			throw new DynamicSOQLException(Label.NoSObject.replace('{sObjectName}', sObjectName));
		}
		List<String> selectItems = new List<String>();
		selectItems.addAll(buildSelectFields());
		selectItems.addAll(buildFunctions());
		selectItems.addAll(buildSubqueries(sObjectDescription));

		return libak_DynamicSOQLConstants.TMPL_QUERY
			.replace(
				libak_DynamicSOQLConstants.PH_SELECT_ITEMS,
				String.join(selectItems, libak_DynamicSOQLConstants.COMMA)
			).replace(
				libak_DynamicSOQLConstants.PH_SOBJECT,
				this.sObjectName
			).replace(
				libak_DynamicSOQLConstants.PH_WHERE,
				this.conditionBlock != null ? 'WHERE ' + this.conditionBlock.stringify(this.sObjectName, this.fieldPathConstructor) : libak_DynamicSOQLConstants.EMPTY_STRING
			).replace(
				libak_DynamicSOQLConstants.PH_GROUP_BY,
				this.groupBy != null ? this.groupBy.stringify(this.sObjectName, this.fieldPathConstructor) : libak_DynamicSOQLConstants.EMPTY_STRING
			).replace(
				libak_DynamicSOQLConstants.PH_ORDER_BY,
				this.orderBy != null ? this.orderBy.stringify() : libak_DynamicSOQLConstants.EMPTY_STRING
			).replace(
				libak_DynamicSOQLConstants.PH_LIMIT,
				this.limitNumber != null ? 'LIMIT '  + this.limitNumber : libak_DynamicSOQLConstants.EMPTY_STRING
			).replace(
				libak_DynamicSOQLConstants.PH_OFFSET,
				this.offsetNumber != null ? 'OFFSET ' + this.offsetNumber : libak_DynamicSOQLConstants.EMPTY_STRING
			)
			.trim()
			.normalizeSpace();
	}

	/* PRIVATE METHODS */

	private List<String> buildSelectFields() {
		if (this.selectFields == null && this.selectFields.isEmpty()) {
			return new List<String>();
		}
		List<String> result = new List<String>();
		for (String fieldApiName : this.selectFields) {
			result.add(String.escapeSingleQuotes(fieldApiName));
		}
		return result;
	}

	private List<String> buildFunctions() {
		if (this.selectFunctions == null || this.selectFunctions.isEmpty()) {
			return new List<String>();
		}
		List<String> result = new List<String>();
		for (libak_DynamicSOQLFunction function : this.selectFunctions) {
			result.add(function.stringify());
		}
		return result;
	}

	private List<String> buildSubqueries(DescribeSObjectResult sObjectDescription) {
		if (this.subQueries == null || this.subQueries.isEmpty()) {
			return new List<String>();
		}

		List<String> result = new List<String>();

		Set<String> sObjectRelationsNames = new Set<String>();
		for (ChildRelationship relationItem : sObjectDescription.getChildRelationships()) {
			sObjectRelationsNames.add(relationItem.getRelationshipName());
		}

		for (String childRelationName : this.subQueries.keySet()) {
			libak_DynamicSOQL subQuery = this.subQueries.get(childRelationName);
			if (!sObjectRelationsNames.contains(childRelationName)) {
				throw new DynamicSOQLException(
					Label.NoChildSObject
						.replace('{childSObjectName}', subQuery.sObjectName)
						.replace('{sObjectName}', this.sObjectName)
				);
			}
			result.add('(' + subQuery.stringify().replace(
				'FROM ' + subQuery.sObjectName,
				'FROM ' + childRelationName
			) + ')');
		}
		return result;
	}

	private Map<String, Set<String>> addFunctionFieldsToFlsMap(Map<String, Set<String>> flsMap) {
		if (this.selectFunctions != null && !this.selectFunctions.isEmpty()) {
			for (libak_DynamicSOQLFunction function : this.selectFunctions) {
				if (String.isNotEmpty(function.fieldApiName())) {
					flsMap.get(this.sObjectName).add(function.fieldApiName());
				}
			}
		}
		return flsMap;
	}

	private Map<String, Set<String>> addSubQueryFieldsToFlsMap(Map<String, Set<String>> flsMap) {
		if (this.subQueries != null && !this.subQueries.isEmpty()) {
			for (libak_DynamicSOQL subQuery : this.subQueries.values()) {
				Map<String, Set<String>> subQueryResult = subQuery.infoToFLSCheck();
				for (String subQuerySObjectName : subQueryResult.keySet()) {
					if (flsMap.containsKey(subQuerySObjectName)) {
						flsMap.get(subQuerySObjectName).addAll(subQueryResult.get(subQuerySObjectName));
					} else {
						flsMap.put(subQuerySObjectName, subQueryResult.get(subQuerySObjectName));
					}
				}
			}
		}
		return flsMap;
	}

	public class DynamicSOQLException extends Exception {}
}
