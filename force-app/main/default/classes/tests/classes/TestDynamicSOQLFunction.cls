@IsTest
public with sharing class TestDynamicSOQLFunction {

	@IsTest
	static void testToStringWithAlias(){
		Test.startTest();
		System.assertEquals(
			'COUNT(Id) alias', new DynamicSOQLFunction('COUNT', 'Id', 'alias').stringify(),
			'The "stringify" method returns wrong value.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testToStringWithoutAlias(){
		Test.startTest();
		System.assertEquals(
			'COUNT(Id)', new DynamicSOQLFunction('COUNT', 'Id').stringify(),
			'The "stringify" method returns wrong value.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testToStringWithoutFieldName(){
		Test.startTest();
		System.assertEquals(
			'COUNT()', new DynamicSOQLFunction('COUNT').stringify(),
			'The "stringify" method returns wrong value.'
		);
		Test.stopTest();
	}

	@IsTest
	static void testFieldApiName(){
		Test.startTest();
		System.assertEquals(
			'Id', new DynamicSOQLFunction('COUNT', 'Id', 'alias').fieldApiName(),
			'The "fieldApiName()" method returns wrong value.'
		);
		Test.stopTest();
	}
}
