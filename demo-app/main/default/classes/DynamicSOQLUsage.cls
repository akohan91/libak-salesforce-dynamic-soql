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
				new libak_DynamicSOQLConditionBlock('AND')
				.addCondition(new libak_DynamicSOQLCondition('Name', 'LIKE', '%Oil%'))
			)
			.withOrderBy(new libak_DynamicSOQLOrderBy(new List<String>{'Name', 'Id'}))
			.withSubQuery(
				'Contacts',
				Soql.factory.build(Contact.SObjectType)
				.withField('FirstName')
				.withField('Email')
				.withConditions(
					new libak_DynamicSOQLConditionBlock('AND')
					.addCondition(new libak_DynamicSOQLCondition('Email', '!=', (String)null))
				)
			).stringify();
		return soqlString;
	}
	
	public static String buildAggregateSoqlString() {
		String soqlString = Soql.factory.build(Opportunity.SObjectType)
			.withField('StageName')
			.withFunction(new libak_DynamicSOQLFunction('SUM', 'Amount', 'amount'))
			.withFunction(new libak_DynamicSOQLFunction('COUNT', 'Id', 'oppCount'))
			.withFunction(new libak_DynamicSOQLFunction('AVG', 'Amount', 'avgAmount'))
			.withGroupBy(
				new libak_DynamicSOQLGroupBy(new List<String>{'StageName'})
				.withHaving(
					new libak_DynamicSOQLConditionBlock('AND')
					.addCondition(new libak_DynamicSOQLCondition(
						new libak_DynamicSOQLFunction('SUM','Amount'), '>', 190)
					)
				)
			).stringify();
		return soqlString;
	}
}