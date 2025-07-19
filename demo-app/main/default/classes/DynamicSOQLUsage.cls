/**
	System.debug(DynamicSOQLUsage.buildSoqlString());
	System.debug(JSON.serializePretty(Database.query(DynamicSOQLUsage.buildSoqlString())));
	System.debug(DynamicSOQLUsage.buildAggregateSoqlString());
	System.debug(JSON.serializePretty(Database.query(DynamicSOQLUsage.buildAggregateSoqlString())));
 */
public with sharing class DynamicSOQLUsage {
	public static String buildSoqlString() {
		String soqlString = Soql.factory.build(Account.SObjectType)
			.withField('Id')
			.withField('Name')
			.withField('OwnerId')
			.withField('Owner.Name')
			.withConditions(
				new DynamicSOQLConditionBlock('AND')
				.addCondition(new DynamicSOQLCondition('Name', 'LIKE', '%Oil%'))
			)
			.withOrderBy(new DynamicSOQLOrderBy(new List<String>{'Name', 'Id'}))
			.withSubQuery(
				'Contacts',
				new DynamicSOQL('Contact')
				.withField('FirstName')
				.withField('Email')
				.withConditions(
					new DynamicSOQLConditionBlock('AND')
					.addCondition(new DynamicSOQLCondition('Email', '!=', (String)null))
				)
			).stringify();
		return soqlString;
	}
	
	public static String buildAggregateSoqlString() {
		String soqlString = Soql.factory.build(Opportunity.SObjectType)
			.withField('StageName')
			.withFunction(new DynamicSOQLFunction('SUM', 'Amount', 'amount'))
			.withFunction(new DynamicSOQLFunction('COUNT', 'Id', 'oppCount'))
			.withFunction(new DynamicSOQLFunction('AVG', 'Amount', 'avgAmount'))
			.withGroupBy(
				new DynamicSOQLGroupBy(new List<String>{'StageName'})
				.withHaving(
					new DynamicSOQLConditionBlock('AND')
					.addCondition(new DynamicSOQLCondition(
						new DynamicSOQLFunction('SUM','Amount'), '>', 190)
					)
				)
			).stringify();
		return soqlString;
	}
}