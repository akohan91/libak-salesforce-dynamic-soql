public with sharing class Soql {
	public static DynamicSOQL.Factory factory = new DynamicSOQL.Factory(
		new FieldPathConstructor()
	);
}