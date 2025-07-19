public with sharing class FieldPathConstructor implements DynamicSOQL.ISobjectFieldPathConstructable {
	public DynamicSOQL.ISobjectFieldPath construct(String sobjectApiName, String fieldPath) {
		return new SobjectFieldPath(sobjectApiName, fieldPath);
	}
}