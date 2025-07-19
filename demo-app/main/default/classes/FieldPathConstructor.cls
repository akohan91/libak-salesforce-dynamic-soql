public with sharing class FieldPathConstructor implements libak_DynamicSOQL.ISobjectFieldPathConstructable {
	public libak_DynamicSOQL.ISobjectFieldPath construct(String sobjectApiName, String fieldPath) {
		return new SobjectFieldPath(sobjectApiName, fieldPath);
	}
}