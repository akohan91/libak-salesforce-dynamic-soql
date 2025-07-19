@IsTest
public with sharing class TestDynamicSOQLEnvironment {
	
	public static DynamicSOQL.Factory factory = new DynamicSOQL.Factory(new TestFieldPathConstructor());

	private class TestFieldPath implements DynamicSOQL.ISobjectFieldPath {
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

	public class TestFieldPathConstructor implements DynamicSOQL.ISobjectFieldPathConstructable {
		public DynamicSOQL.ISobjectFieldPath construct(String sObjectType, String fieldPath) {
			return new TestFieldPath(sObjectType, fieldPath);
		}
	}
}