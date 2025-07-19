@IsTest
public with sharing class libak_TestDynamicSOQLFunction {

	@IsTest
	static void testToStringWithAlias(){
		Test.startTest();
		System.assertEquals(
			'COUNT(Id) alias', new libak_DynamicSOQLFunction('COUNT', 'Id', 'alias').stringify(),
			'The "stringify" method returns wrong value.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testToStringWithoutAlias(){
		Test.startTest();
		System.assertEquals(
			'COUNT(Id)', new libak_DynamicSOQLFunction('COUNT', 'Id').stringify(),
			'The "stringify" method returns wrong value.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testToStringWithoutFieldName(){
		Test.startTest();
		System.assertEquals(
			'COUNT()', new libak_DynamicSOQLFunction('COUNT').stringify(),
			'The "stringify" method returns wrong value.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testFieldApiName(){
		Test.startTest();
		System.assertEquals(
			'Id', new libak_DynamicSOQLFunction('COUNT', 'Id', 'alias').fieldApiName(),
			'The "fieldApiName()" method returns wrong value.'
		);
		Test.stopTest();
	}
}
