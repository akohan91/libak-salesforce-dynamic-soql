# Table of content

- [Table of content](#table-of-content)
- [Intro](#intro)
- [Quick Start](#quick-start)
  - [Build a regular query](#build-a-regular-query)
  - [Build an aggregated query](#build-an-aggregated-query)
- [Reference Guide](#reference-guide)
  - [libak_DynamicSOQL](#dynamicsoql)
    - [Constructors](#constructors)
    - [Methods](#methods)
  - [libak_DynamicSOQLFunction](#dynamicsoqlfunction)
    - [Constructors](#constructors-1)
    - [Methods](#methods-1)
  - [libak_DynamicSOQLConditionBlock](#dynamicsoqlconditionblock)
    - [Constructors](#constructors-2)
    - [Methods](#methods-2)
  - [libak_DynamicSOQLCondition](#dynamicsoqlcondition)
    - [Constructors](#constructors-3)
    - [Methods](#methods-3)
  - [libak_DynamicSOQLOrderBy](#dynamicsoqlorderby)
    - [Constructors](#constructors-4)
    - [Methods](#methods-4)
  - [libak_DynamicSOQLGroupBy](#dynamicsoqlgroupby)
    - [Constructors](#constructors-5)
    - [Methods](#methods-5)

# Intro

**Important**

The ***libak_DynamicSOQL*** module depends on the ***DatabaseUtils*** module.

Enter libak_DynamicSOQL, a powerful and flexible library that enables you to retrieve data from Salesforce using Apex Code and JavaScript. This library provides a unique, object-oriented approach to building SOQL queries, making it easier to build and manage complex queries.

libak_DynamicSOQL is built using Apex code and a JavaScript mirror, and it provides a number of features that make it a powerful and versatile solution for working with SOQL. Some of the key features of libak_DynamicSOQL include:

- Apec API: libak_DynamicSOQL provides an easy-to-use API that is fully object-oriented. This makes it easy to build and manage complex queries, as you can use objects to represent the various parts of your query.

- JavaScript API: libak_DynamicSOQL includes a JavaScript API that allows you to build the JSON representation of your query and then send it to the backend to process. This means you can build your query on the frontend and then process it on the backend, providing a seamless and efficient data retrieval solution.

- Granular Control: libak_DynamicSOQL enables you to build your query granularly, meaning you can prepare different parts of the query separately. For example, you can use the libak_DynamicSOQLConditionBlock and libak_DynamicSOQLCondition objects to prepare the JSON representation of your filters, and then build the WHERE clause on the backend.

- Security: libak_DynamicSOQL includes security measures to prevent SOQL injection on the backend. This ensures that your queries are secure and protects your data from malicious attacks.

- Functionality: libak_DynamicSOQL provides a wide range of functionality, including the ability to build simple queries, aggregate queries, subqueries, and more.

The library is built in Object Oriented style and contains the next classes:

- **libak_DynamicSOQL** - the main class that represents SOQL.
- **libak_DynamicSOQLCondition** - represents the part of 'WHERE' clause in a base format like `<FieldName> <operator> <value>'`.
- **libak_DynamicSOQLConditionBlock** - used to combine **libak_DynamicSOQLCondition** or nested **libak_DynamicSOQLConditionBlock** and allows to build logical bloks with `OR | AND` keywords.
- **libak_DynamicSOQLFunction** - represent SOQL Functions, for example: `COUNT(Id) alias`.
- **libak_DynamicSOQLGroupBy** - represent `GROUP BY` clause and allows to build Aggregated Query.
- **libak_DynamicSOQLOrderBy** - represent `ORDER BY` clause.

# Quick Start

## Build a regular query

```java
libak_DynamicSOQL soql = new libak_DynamicSOQL('Account')
.withField('Id')
.withField('Name')
.withConditions(
    new libak_DynamicSOQLConditionBlock('AND')
    .addCondition(new libak_DynamicSOQLCondition('Name', '=', 'Some Account Name'))
)
.withOrderBy(new libak_DynamicSOQLOrderBy(new List<String>{'Name', 'Id'}))
.withSubQuery(
    'Contacts',
    new libak_DynamicSOQL('Contact')
    .withField('FirstName')
    .withField('Email')
    .withConditions(
        new libak_DynamicSOQLConditionBlock('AND')
        .addCondition(new libak_DynamicSOQLCondition('Email', '!=', (String)null))
    )
);

System.debug(soql.stringify());
/* The output (line breaks was added manually):
    SELECT Id,Name,(
        SELECT FirstName,Email
        FROM Contacts
        WHERE (Email != null)
    )
    FROM Account
    WHERE (Name = 'Some Account Name')
    ORDER BY Name,Id ASC NULLS LAST
*/
```

## Build an aggregated query

```java
libak_DynamicSOQL soql = new libak_DynamicSOQL('Opportunity')
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
);

System.debug(soql.stringify());

/* The output (line breaks was added manually):
    SELECT StageName,
        SUM(Amount) amount,
        COUNT(Id) oppCount,
        AVG(Amount) avgAmount
    FROM Opportunity
    GROUP BY StageName
        HAVING (SUM(Amount) > 190)
*/
```


# Reference Guide






## libak_DynamicSOQL

### Constructors

The following are constructors for libak_DynamicSOQL.
- `libak_DynamicSOQL(String sObjectName)`
```java
libak_DynamicSOQL soql = new libak_DynamicSOQL('Account');
```

### Methods

The following are methods for libak_DynamicSOQL. All are instance methods.

- **withField** <br>
`withField(String fieldName): libak_DynamicSOQL` <br>
Adds a field to SELECT statement
```java
System.debug(
    new libak_DynamicSOQL('Account')
    .withField('Id')
    .withField('Name')
    .withField('OwnerId')
    .stringify()
); // SELECT Id,Name,OwnerId FROM Account
```

- **withFunction** <br>
`withFunction(libak_DynamicSOQLFunction function): libak_DynamicSOQL` <br>
Adds a function to SELECT statement like "COUNT(Id) recordsCount"
```java
System.debug(
    new libak_DynamicSOQL('Account')
    .withFunction(new libak_DynamicSOQLFunction('COUNT', ''))
    .stringify()
); // SELECT COUNT() FROM Account
```

- **withSubQuery** <br>
`withSubQuery(String relationshipName, libak_DynamicSOQL subQuery): libak_DynamicSOQL` <br>
Adds a subquery

```java
System.debug(
    new libak_DynamicSOQL('Account')
    .withField('Name')
    .withSubQuery(
        'Contacts',
        new libak_DynamicSOQL('Contact')
        .withField('Id')
    ).stringify()
); // SELECT Name,(SELECT Id FROM Contacts) FROM Account
```

- **withConditions** <br>
`withConditions(libak_DynamicSOQLConditionBlock conditionBlock): libak_DynamicSOQL` <br>
Adds a condition block to the query

```java
System.debug(
    new libak_DynamicSOQL('Account')
    .withField('Id')
    .withConditions(
        new libak_DynamicSOQLConditionBlock('AND')
        .addCondition(new libak_DynamicSOQLCondition('Name', '=', 'Test'))
        .addCondition(new libak_DynamicSOQLCondition('CreatedDate', '>', Date.newInstance(2022, 01, 01)))
    ).stringify()
); // SELECT Id FROM Account WHERE (Name = 'Test' AND CreatedDate > 2022-01-01)
```

- **withGroupBy** <br>
`withGroupBy(libak_DynamicSOQLGroupBy groupBy): libak_DynamicSOQL` <br>
Adds a GROUP BY statement to the query

```java
System.debug(
    new libak_DynamicSOQL('Opportunity')
    .withField('StageName')
    .withFunction(new libak_DynamicSOQLFunction('SUM', 'Amount', 'amount'))
    .withGroupBy(
        new libak_DynamicSOQLGroupBy(new List<String>{'StageName'})
        .withHaving(
            new libak_DynamicSOQLConditionBlock('AND')
            .addCondition(new libak_DynamicSOQLCondition(
                new libak_DynamicSOQLFunction('SUM','Amount'), '>', 190)
            )
        )
    ).stringify()
); // SELECT StageName,SUM(Amount) amount FROM Opportunity GROUP BY StageName HAVING (SUM(Amount) > 190)
```

- **withOrderBy** <br>
`withOrderBy(libak_DynamicSOQLOrderBy orderBy): libak_DynamicSOQL` <br>
Adds a ORDER BY statement to the query

```java
System.debug(
    new libak_DynamicSOQL('Account')
    .withField('Name')
    .withOrderBy(new libak_DynamicSOQLOrderBy(new List<String>{'Name'}))
    .stringify()
); // SELECT Name FROM Account ORDER BY Name ASC NULLS LAST
```

- **withOffset** <br>
`withOffset(Integer offsetNumber): libak_DynamicSOQL` <br>
Adds OFFSET statement to SOQL

```java
System.debug(
    new libak_DynamicSOQL('Account')
    .withField('Id')
    .withOffset(0)
    .withLimit(10)
    .stringify()
); // SELECT Id FROM Account LIMIT 10 OFFSET 0
```

- **withLimit** <br>
`withLimit(Integer limitNumber): libak_DynamicSOQL` <br>
Adds LIMIT statement to SOQL

```java
System.debug(
    new libak_DynamicSOQL('Account')
    .withField('Id')
    .withOffset(0)
    .withLimit(10)
    .stringify()
); // SELECT Id FROM Account LIMIT 10 OFFSET 0
```

- **infoToFLSCheck** <br>
`infoToFLSCheck(): Map<String, Set<String>>` <br>
Returns the Map in format: `sObjectApiName => Set<String>{fieldApiName}`

```java
System.debug(
    new libak_DynamicSOQL('Account')
    .withFunction(new libak_DynamicSOQLFunction('COUNT', 'Id'))
    .withField('Name')
    .withSubQuery(
        'Contact',
        new libak_DynamicSOQL('Contact')
        .withField('Id')
        .withField('FirstName')
    )
    .withConditions(
        new libak_DynamicSOQLConditionBlock('AND')
        .addCondition(new libak_DynamicSOQLCondition('Phone', '=', '12345'))
    )
    .withOrderBy(new libak_DynamicSOQLOrderBy(new List<String>{'Industry'}))
    .infoToFLSCheck()
);

/*
{
    Account={Id, Industry, Name, Phone},
    Contact={FirstName, Id}
}
*/
```

- **stringify** <br>
`stringify(): String` <br>
Builds a SOQL string

```java
new libak_DynamicSOQL('Account')
.withField('Id')
.withSubQuery('Contacts', new libak_DynamicSOQL('Contact').withField('Id'))
.stringify(); // SELECT Id,(SELECT Id FROM Contacts) FROM Account
```






## libak_DynamicSOQLFunction

### Constructors

The following are constructors for libak_DynamicSOQLFunction.
- `libak_DynamicSOQLFunction(String functionName)`
```java
libak_DynamicSOQLFunction function = new libak_DynamicSOQLFunction('COUNT');
System.debug(function.stringify()); // COUNT()
```
- `libak_DynamicSOQLFunction(String functionName, String fieldName)`
```java
libak_DynamicSOQLFunction function = new libak_DynamicSOQLFunction('COUNT', 'Id');
System.debug(function.stringify()); // COUNT(Id)
```
- `libak_DynamicSOQLFunction(String functionName, String fieldName, String alias)`
```java
libak_DynamicSOQLFunction function = new libak_DynamicSOQLFunction('COUNT', 'Id', 'recordsCount');
System.debug(function.stringify()); // COUNT(Id) recordsCount
```

### Methods

The following are methods for libak_DynamicSOQLFunction. All are instance methods.

- **fieldApiName** <br>
`fieldApiName(): String` <br>
Returns the field api name that is used in a formula.

```java
new libak_DynamicSOQLFunction('COUNT', 'Id', 'alias')
.fieldApiname() // Id
```

- **stringify** <br>
`stringify(): String` <br>
Builds a SOQL function string like `COUNT(Id) recordsCount`

```java
new libak_DynamicSOQLFunction('COUNT', 'Id', 'alias')
.stringify() // COUNT(Id) alias
```






## libak_DynamicSOQLConditionBlock

### Constructors

The following are constructors for libak_DynamicSOQLConditionBlock.

- `libak_DynamicSOQLConditionBlock(String operator)`

```java
libak_DynamicSOQLConditionBlock conditionBlock = new libak_DynamicSOQLConditionBlock('AND')
```

### Methods

The following are methods for libak_DynamicSOQLConditionBlock. All are instance methods.

- **addCondition** <br>
`addCondition(libak_DynamicSOQLCondition condition): libak_DynamicSOQLConditionBlock` <br>
Adds a condition to the current block

```java
libak_DynamicSOQLConditionBlock conditionBlock = new libak_DynamicSOQLConditionBlock('OR')
.addCondition(
    new libak_DynamicSOQLCondition('Name', '=', 'Test_1')
);

System.debug(conditionBlock.stringify('Account')); // (Name = 'Test_1')

conditionBlock
.addCondition(new libak_DynamicSOQLCondition('Name', '=', 'Test_2'));
System.debug(conditionBlock.stringify('Account')); // (Name = 'Test_1' OR Name = 'Test_2')
```

- **addConditionBlock** <br>
`addConditionBlock(libak_DynamicSOQLConditionBlock conditionBlock): libak_DynamicSOQLConditionBlock` <br>
Adds new condition block that will be added to the current one. It allow to build complex conditions like
`(condition OR condition) AND condition`

```java
libak_DynamicSOQLConditionBlock conditionBlock = new libak_DynamicSOQLConditionBlock('AND')
.addCondition(new libak_DynamicSOQLCondition('Name', '=', 'Test1'))
.addConditionBlock(
    new libak_DynamicSOQLConditionBlock('OR')
    .addCondition(new libak_DynamicSOQLCondition('Phone', '=', '12345'))
    .addCondition(new libak_DynamicSOQLCondition('Phone', '=', '123456'))
);

System.debug(conditionBlock.stringify('Account')); // ((Phone = '12345' OR Phone = '123456') AND Name = 'Test1')
```

- **switchOperator** <br>
`switchOperator(String operator): libak_DynamicSOQLConditionBlock`
Changes the operator. Could be either `OR | AND`

```java
libak_DynamicSOQLConditionBlock conditionBlock = new libak_DynamicSOQLConditionBlock('AND')
.addCondition(new libak_DynamicSOQLCondition('Phone', '=', '12345'))
.addCondition(new libak_DynamicSOQLCondition('Phone', '=', '123456'));

System.debug(conditionBlock.stringify('Account')); // (Phone = '12345' AND Phone = '123456')
conditionBlock.switchOperator('OR');
System.debug(conditionBlock.stringify('Account')); // (Phone = '12345' OR Phone = '123456')
```

- **fieldsApiNames** <br>
`fieldsApiNames(): Set<String>` <br>
Returns all field api names from libak_DynamicSOQLCondition and libak_DynamicSOQLConditionBlock

```java
libak_DynamicSOQLConditionBlock conditionBlock = new libak_DynamicSOQLConditionBlock('AND')
.addCondition(new libak_DynamicSOQLCondition('Phone', '=', '121345'))
.addCondition(new libak_DynamicSOQLCondition('FirstName', '=', 'Test'))
.addCondition(new libak_DynamicSOQLCondition('LastName', '=', 'Test'));

conditionBlock.fieldsApiNames(); // {'Phone', 'FirstName', 'LastName'}
```

- **stringify** <br>
`stringify(String sobjectApiName): String` <br>
Builds a Dynamic SOQL Condition Block string for WHERE statement






## libak_DynamicSOQLCondition

### Constructors

The following are constructors for libak_DynamicSOQLCondition.

- `libak_DynamicSOQLCondition(String fieldName, String operator, Object value)`

```java
libak_DynamicSOQLCondition booleanCondition = new libak_DynamicSOQLCondition('isActive', '=', true);
libak_DynamicSOQLCondition numberCondition = new libak_DynamicSOQLCondition('Amount', '>=', 100);
```

- `libak_DynamicSOQLCondition(libak_DynamicSOQLFunction function, String operator, Object value)`

```java
libak_DynamicSOQLCondition condition = new libak_DynamicSOQLCondition(
    new libak_DynamicSOQLFunction('COUNT', 'Amount'),
    '>',
    100
);
```

- `libak_DynamicSOQLCondition(String fieldName, String operator, Datetime value)`

```java
libak_DynamicSOQLCondition condition = new libak_DynamicSOQLCondition('CreatedDate', '>', Datetime.newInstance(2022, 01, 01, 01, 01, 01));
```

- `libak_DynamicSOQLCondition(String fieldName, String operator, Date value)`

```java
libak_DynamicSOQLCondition condition = new libak_DynamicSOQLCondition('CreatedDate', '>', Date.newInstance(2022, 01, 01));
```

- `libak_DynamicSOQLCondition(String fieldName, String operator, String value)`

```java
libak_DynamicSOQLCondition stringCondition = new libak_DynamicSOQLCondition('Name', '=', 'It\'s a string');

Set<Id> someVariable = new Set<Id>{'id_1','id_2','id_3'}
libak_DynamicSOQLCondition variableCondition = new libak_DynamicSOQLCondition('Id', 'IN:', 'someVariable');
```


### Methods

The following are methods for libak_DynamicSOQLCondition. All are instance methods.

- **fieldApiName** <br>
`fieldApiName(): String` <br>
Returns the field api name that is used in a condition.

- **stringify** <br>
`stringify(String sobjectApiName): String` <br>
Builds a SOQL condition string like `Name = 'Andrew'`






## libak_DynamicSOQLOrderBy

### Constructors

The following are constructors for libak_DynamicSOQLOrderBy.

- `libak_DynamicSOQLOrderBy(List<String> orderByFields)`
```java
libak_DynamicSOQLOrderBy orderBy = new libak_DynamicSOQLOrderBy(new List<String>{'Name', 'Id'});
```

- `libak_DynamicSOQLOrderBy(List<String> orderByFields, Boolean isDESC)`
```java
libak_DynamicSOQLOrderBy orderBy = new libak_DynamicSOQLOrderBy(new List<String>{'Name', 'Id'}, true);
```

- `libak_DynamicSOQLOrderBy(List<String> orderByFields, Boolean isDESC, Boolean isNullsFirst)`
```java
libak_DynamicSOQLOrderBy orderBy = new libak_DynamicSOQLOrderBy(new List<String>{'Name', 'Id'}, true, true);
```

### Methods

The following are methods for libak_DynamicSOQLOrderBy. All are instance methods.

- **fieldsApiNames** <br>
`fieldsApiNames(): Set<String>` <br>
Returns list of fields that are used in ORDER BY Statement

- **stringify** <br>
`stringify(): String` <br>
Returns ORDER BY statement like: "ORDER BY Name ASC NULLS LAST"






## libak_DynamicSOQLGroupBy

### Constructors

The following are constructors for libak_DynamicSOQLGroupBy.

- `libak_DynamicSOQLGroupBy(List<String> fieldGroupByList)`
```java
libak_DynamicSOQLGroupBy groupBy = new libak_DynamicSOQLGroupBy(new List<String>{'StageName'});
```

### Methods

The following are methods for libak_DynamicSOQLGroupBy. All are instance methods.

- **fieldsApiNames** <br>
`fieldsApiNames(): Set<String>` <br>
Returns list of fields that are used in GROUP BY Statement

- **withHaving** <br>
`withHaving(libak_DynamicSOQLConditionBlock conditionBlock): libak_DynamicSOQLGroupBy` <br>
Adds HAVING clause to the GROUP BY clause

- **stringify** <br>
`stringify(String sobjectApiName): String` <br>
Builds a GROUP BY part of SOQL string
