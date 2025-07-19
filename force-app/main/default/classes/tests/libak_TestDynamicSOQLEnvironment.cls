@IsTest
public with sharing class libak_TestDynamicSOQLEnvironment {
	
	public static libak_DynamicSOQL.Factory factory = new libak_DynamicSOQL.Factory(new TestFieldPathConstructor());

	private class TestFieldPath implements libak_DynamicSOQL.ISobjectFieldPath {
		private Map<String,Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
		private String sObjectName;
		private String fieldPath;

		public TestFieldPath(String sObjectName, String fieldPath) {
			this.sObjectName = sObjectName;
			this.fieldPath = fieldPath;
		}

		public Schema.DescribeFieldResult targetFieldDescribe() {
			return this.globalDescribe.get(this.sObjectName).getDescribe().fields.getMap().get(this.fieldPath)?.getDescribe();
		}
	}

	public class TestFieldPathConstructor implements libak_DynamicSOQL.ISobjectFieldPathConstructable {
		public libak_DynamicSOQL.ISobjectFieldPath construct(String sObjectType, String fieldPath) {
			return new TestFieldPath(sObjectType, fieldPath);
		}
	}
}