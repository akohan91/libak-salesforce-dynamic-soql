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