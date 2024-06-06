/**
 * @author Andrei Kakhanouski <akohan91@gmail.com>
 * The ISobjectFieldPath interface defines a method for retrieving the field description of a target field.
 */
public interface ISobjectFieldPath {
	
	/**
	 * Returns the DescribeFieldResult for a target field.
	 * @return the DescribeFieldResult for the target field.
	 */
	Schema.DescribeFieldResult targetFieldDescribe();
}
