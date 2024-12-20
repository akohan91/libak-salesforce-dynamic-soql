# Table of content

- [Table of content](#table-of-content)
- [Intro](#intro)
- [Quick Start](#quick-start)
  - [Build a regular query](#build-a-regular-query)
  - [Build an aggregated query](#build-an-aggregated-query)
- [Reference Guide](#reference-guide)
  - [DynamicSOQL](#dynamicsoql)
    - [Constructors](#constructors)
    - [Methods](#methods)
  - [DynamicSOQLFunction](#dynamicsoqlfunction)
    - [Constructors](#constructors-1)
    - [Methods](#methods-1)
  - [DynamicSOQLConditionBlock](#dynamicsoqlconditionblock)
    - [Constructors](#constructors-2)
    - [Methods](#methods-2)
  - [DynamicSOQLCondition](#dynamicsoqlcondition)
    - [Constructors](#constructors-3)
    - [Methods](#methods-3)
  - [DynamicSOQLOrderBy](#dynamicsoqlorderby)
    - [Constructors](#constructors-4)
    - [Methods](#methods-4)
  - [DynamicSOQLGroupBy](#dynamicsoqlgroupby)
    - [Constructors](#constructors-5)
    - [Methods](#methods-5)

# Intro

**Important**

The ***DynamicSOQL*** module depends on the ***DatabaseUtils*** module.

Enter DynamicSOQL, a powerful and flexible library that enables you to retrieve data from Salesforce using Apex Code and JavaScript. This library provides a unique, object-oriented approach to building SOQL queries, making it easier to build and manage complex queries.

DynamicSOQL is built using Apex code and a JavaScript mirror, and it provides a number of features that make it a powerful and versatile solution for working with SOQL. Some of the key features of DynamicSOQL include:

- Apec API: DynamicSOQL provides an easy-to-use API that is fully object-oriented. This makes it easy to build and manage complex queries, as you can use objects to represent the various parts of your query.

- JavaScript API: DynamicSOQL includes a JavaScript API that allows you to build the JSON representation of your query and then send it to the backend to process. This means you can build your query on the frontend and then process it on the backend, providing a seamless and efficient data retrieval solution.

- Granular Control: DynamicSOQL enables you to build your query granularly, meaning you can prepare different parts of the query separately. For example, you can use the DynamicSOQLConditionBlock and DynamicSOQLCondition objects to prepare the JSON representation of your filters, and then build the WHERE clause on the backend.

- Security: DynamicSOQL includes security measures to prevent SOQL injection on the backend. This ensures that your queries are secure and protects your data from malicious attacks.

- Functionality: DynamicSOQL provides a wide range of functionality, including the ability to build simple queries, aggregate queries, subqueries, and more.

The library is built in Object Oriented style and contains the next classes:

- **DynamicSOQL** - the main class that represents SOQL.
- **DynamicSOQLCondition** - represents the part of 'WHERE' clause in a base format like `<FieldName> <operator> <value>'`.
- **DynamicSOQLConditionBlock** - used to combine **DynamicSOQLCondition** or nested **DynamicSOQLConditionBlock** and allows to build logical bloks with `OR | AND` keywords.
- **DynamicSOQLFunction** - represent SOQL Functions, for example: `COUNT(Id) alias`.
- **DynamicSOQLGroupBy** - represent `GROUP BY` clause and allows to build Aggregated Query.
- **DynamicSOQLOrderBy** - represent `ORDER BY` clause.

# Quick Start

## Build a regular query

```java
DynamicSOQL soql = new DynamicSOQL('Account')
.withField('Id')
.withField('Name')
.withConditions(
    new DynamicSOQLConditionBlock('AND')
    .addCondition(new DynamicSOQLCondition('Name', '=', 'Some Account Name'))
)
.withOrderBy(new DynamicSOQLOrderBy(new List<String>{'Name', 'Id'}))
.withSubQuery(
    'Contacts',
    new DynamicSOQL('Contact')
    .withField('FirstName')
    .withField('Email')
    .withConditions(
        new DynamicSOQLConditionBlock('AND')
        .addCondition(new DynamicSOQLCondition('Email', '!=', (String)null))
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
DynamicSOQL soql = new DynamicSOQL('Opportunity')
.withField('StageName')
.withFunction(new DynamicSOQLFunction('SUM', 'Amount', 'amount'))
.withFunction(new DynamicSOQLFunction('COUNT', 'Id', 'oppCount'))
.withFunction(new DynamicSOQLFunction('AVG', 'Amount', 'avgAmount'))
.withGroupBy(
    new DynamicSOQLGroupBy(new List<String>{'StageName'})
    .withHaving(
        new DynamicSOQLConditionBlock('AND')
        .addCondition(new DynamicSOQLCondition(
            new DynamicSOQLFunction('SUM','Amount'), '>', 190)
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






## DynamicSOQL

### Constructors

The following are constructors for DynamicSOQL.
- `DynamicSOQL(String sObjectName)`
```java
DynamicSOQL soql = new DynamicSOQL('Account');
```

### Methods

The following are methods for DynamicSOQL. All are instance methods.

- **withField** <br>
`withField(String fieldName): DynamicSOQL` <br>
Adds a field to SELECT statement
```java
System.debug(
    new DynamicSOQL('Account')
    .withField('Id')
    .withField('Name')
    .withField('OwnerId')
    .stringify()
); // SELECT Id,Name,OwnerId FROM Account
```

- **withFunction** <br>
`withFunction(DynamicSOQLFunction function): DynamicSOQL` <br>
Adds a function to SELECT statement like "COUNT(Id) recordsCount"
```java
System.debug(
    new DynamicSOQL('Account')
    .withFunction(new DynamicSOQLFunction('COUNT', ''))
    .stringify()
); // SELECT COUNT() FROM Account
```

- **withSubQuery** <br>
`withSubQuery(String relationshipName, DynamicSOQL subQuery): DynamicSOQL` <br>
Adds a subquery

```java
System.debug(
    new DynamicSOQL('Account')
    .withField('Name')
    .withSubQuery(
        'Contacts',
        new DynamicSOQL('Contact')
        .withField('Id')
    ).stringify()
); // SELECT Name,(SELECT Id FROM Contacts) FROM Account
```

- **withConditions** <br>
`withConditions(DynamicSOQLConditionBlock conditionBlock): DynamicSOQL` <br>
Adds a condition block to the query

```java
System.debug(
    new DynamicSOQL('Account')
    .withField('Id')
    .withConditions(
        new DynamicSOQLConditionBlock('AND')
        .addCondition(new DynamicSOQLCondition('Name', '=', 'Test'))
        .addCondition(new DynamicSOQLCondition('CreatedDate', '>', Date.newInstance(2022, 01, 01)))
    ).stringify()
); // SELECT Id FROM Account WHERE (Name = 'Test' AND CreatedDate > 2022-01-01)
```

- **withGroupBy** <br>
`withGroupBy(DynamicSOQLGroupBy groupBy): DynamicSOQL` <br>
Adds a GROUP BY statement to the query

```java
System.debug(
    new DynamicSOQL('Opportunity')
    .withField('StageName')
    .withFunction(new DynamicSOQLFunction('SUM', 'Amount', 'amount'))
    .withGroupBy(
        new DynamicSOQLGroupBy(new List<String>{'StageName'})
        .withHaving(
            new DynamicSOQLConditionBlock('AND')
            .addCondition(new DynamicSOQLCondition(
                new DynamicSOQLFunction('SUM','Amount'), '>', 190)
            )
        )
    ).stringify()
); // SELECT StageName,SUM(Amount) amount FROM Opportunity GROUP BY StageName HAVING (SUM(Amount) > 190)
```

- **withOrderBy** <br>
`withOrderBy(DynamicSOQLOrderBy orderBy): DynamicSOQL` <br>
Adds a ORDER BY statement to the query

```java
System.debug(
    new DynamicSOQL('Account')
    .withField('Name')
    .withOrderBy(new DynamicSOQLOrderBy(new List<String>{'Name'}))
    .stringify()
); // SELECT Name FROM Account ORDER BY Name ASC NULLS LAST
```

- **withOffset** <br>
`withOffset(Integer offsetNumber): DynamicSOQL` <br>
Adds OFFSET statement to SOQL

```java
System.debug(
    new DynamicSOQL('Account')
    .withField('Id')
    .withOffset(0)
    .withLimit(10)
    .stringify()
); // SELECT Id FROM Account LIMIT 10 OFFSET 0
```

- **withLimit** <br>
`withLimit(Integer limitNumber): DynamicSOQL` <br>
Adds LIMIT statement to SOQL

```java
System.debug(
    new DynamicSOQL('Account')
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
    new DynamicSOQL('Account')
    .withFunction(new DynamicSOQLFunction('COUNT', 'Id'))
    .withField('Name')
    .withSubQuery(
        'Contact',
        new DynamicSOQL('Contact')
        .withField('Id')
        .withField('FirstName')
    )
    .withConditions(
        new DynamicSOQLConditionBlock('AND')
        .addCondition(new DynamicSOQLCondition('Phone', '=', '12345'))
    )
    .withOrderBy(new DynamicSOQLOrderBy(new List<String>{'Industry'}))
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
new DynamicSOQL('Account')
.withField('Id')
.withSubQuery('Contacts', new DynamicSOQL('Contact').withField('Id'))
.stringify(); // SELECT Id,(SELECT Id FROM Contacts) FROM Account
```






## DynamicSOQLFunction

### Constructors

The following are constructors for DynamicSOQLFunction.
- `DynamicSOQLFunction(String functionName)`
```java
DynamicSOQLFunction function = new DynamicSOQLFunction('COUNT');
System.debug(function.stringify()); // COUNT()
```
- `DynamicSOQLFunction(String functionName, String fieldName)`
```java
DynamicSOQLFunction function = new DynamicSOQLFunction('COUNT', 'Id');
System.debug(function.stringify()); // COUNT(Id)
```
- `DynamicSOQLFunction(String functionName, String fieldName, String alias)`
```java
DynamicSOQLFunction function = new DynamicSOQLFunction('COUNT', 'Id', 'recordsCount');
System.debug(function.stringify()); // COUNT(Id) recordsCount
```

### Methods

The following are methods for DynamicSOQLFunction. All are instance methods.

- **fieldApiName** <br>
`fieldApiName(): String` <br>
Returns the field api name that is used in a formula.

```java
new DynamicSOQLFunction('COUNT', 'Id', 'alias')
.fieldApiname() // Id
```

- **stringify** <br>
`stringify(): String` <br>
Builds a SOQL function string like `COUNT(Id) recordsCount`

```java
new DynamicSOQLFunction('COUNT', 'Id', 'alias')
.stringify() // COUNT(Id) alias
```






## DynamicSOQLConditionBlock

### Constructors

The following are constructors for DynamicSOQLConditionBlock.

- `DynamicSOQLConditionBlock(String operator)`

```java
DynamicSOQLConditionBlock conditionBlock = new DynamicSOQLConditionBlock('AND')
```

### Methods

The following are methods for DynamicSOQLConditionBlock. All are instance methods.

- **addCondition** <br>
`addCondition(DynamicSOQLCondition condition): DynamicSOQLConditionBlock` <br>
Adds a condition to the current block

```java
DynamicSOQLConditionBlock conditionBlock = new DynamicSOQLConditionBlock('OR')
.addCondition(
    new DynamicSOQLCondition('Name', '=', 'Test_1')
);

System.debug(conditionBlock.stringify('Account')); // (Name = 'Test_1')

conditionBlock
.addCondition(new DynamicSOQLCondition('Name', '=', 'Test_2'));
System.debug(conditionBlock.stringify('Account')); // (Name = 'Test_1' OR Name = 'Test_2')
```

- **addConditionBlock** <br>
`addConditionBlock(DynamicSOQLConditionBlock conditionBlock): DynamicSOQLConditionBlock` <br>
Adds new condition block that will be added to the current one. It allow to build complex conditions like
`(condition OR condition) AND condition`

```java
DynamicSOQLConditionBlock conditionBlock = new DynamicSOQLConditionBlock('AND')
.addCondition(new DynamicSOQLCondition('Name', '=', 'Test1'))
.addConditionBlock(
    new DynamicSOQLConditionBlock('OR')
    .addCondition(new DynamicSOQLCondition('Phone', '=', '12345'))
    .addCondition(new DynamicSOQLCondition('Phone', '=', '123456'))
);

System.debug(conditionBlock.stringify('Account')); // ((Phone = '12345' OR Phone = '123456') AND Name = 'Test1')
```

- **switchOperator** <br>
`switchOperator(String operator): DynamicSOQLConditionBlock`
Changes the operator. Could be either `OR | AND`

```java
DynamicSOQLConditionBlock conditionBlock = new DynamicSOQLConditionBlock('AND')
.addCondition(new DynamicSOQLCondition('Phone', '=', '12345'))
.addCondition(new DynamicSOQLCondition('Phone', '=', '123456'));

System.debug(conditionBlock.stringify('Account')); // (Phone = '12345' AND Phone = '123456')
conditionBlock.switchOperator('OR');
System.debug(conditionBlock.stringify('Account')); // (Phone = '12345' OR Phone = '123456')
```

- **fieldsApiNames** <br>
`fieldsApiNames(): Set<String>` <br>
Returns all field api names from DynamicSOQLCondition and DynamicSOQLConditionBlock

```java
DynamicSOQLConditionBlock conditionBlock = new DynamicSOQLConditionBlock('AND')
.addCondition(new DynamicSOQLCondition('Phone', '=', '121345'))
.addCondition(new DynamicSOQLCondition('FirstName', '=', 'Test'))
.addCondition(new DynamicSOQLCondition('LastName', '=', 'Test'));

conditionBlock.fieldsApiNames(); // {'Phone', 'FirstName', 'LastName'}
```

- **stringify** <br>
`stringify(String sobjectApiName): String` <br>
Builds a Dynamic SOQL Condition Block string for WHERE statement






## DynamicSOQLCondition

### Constructors

The following are constructors for DynamicSOQLCondition.

- `DynamicSOQLCondition(String fieldName, String operator, Object value)`

```java
DynamicSOQLCondition booleanCondition = new DynamicSOQLCondition('isActive', '=', true);
DynamicSOQLCondition numberCondition = new DynamicSOQLCondition('Amount', '>=', 100);
```

- `DynamicSOQLCondition(DynamicSOQLFunction function, String operator, Object value)`

```java
DynamicSOQLCondition condition = new DynamicSOQLCondition(
    new DynamicSOQLFunction('COUNT', 'Amount'),
    '>',
    100
);
```

- `DynamicSOQLCondition(String fieldName, String operator, Datetime value)`

```java
DynamicSOQLCondition condition = new DynamicSOQLCondition('CreatedDate', '>', Datetime.newInstance(2022, 01, 01, 01, 01, 01));
```

- `DynamicSOQLCondition(String fieldName, String operator, Date value)`

```java
DynamicSOQLCondition condition = new DynamicSOQLCondition('CreatedDate', '>', Date.newInstance(2022, 01, 01));
```

- `DynamicSOQLCondition(String fieldName, String operator, String value)`

```java
DynamicSOQLCondition stringCondition = new DynamicSOQLCondition('Name', '=', 'It\'s a string');

Set<Id> someVariable = new Set<Id>{'id_1','id_2','id_3'}
DynamicSOQLCondition variableCondition = new DynamicSOQLCondition('Id', 'IN:', 'someVariable');
```


### Methods

The following are methods for DynamicSOQLCondition. All are instance methods.

- **fieldApiName** <br>
`fieldApiName(): String` <br>
Returns the field api name that is used in a condition.

- **stringify** <br>
`stringify(String sobjectApiName): String` <br>
Builds a SOQL condition string like `Name = 'Andrew'`






## DynamicSOQLOrderBy

### Constructors

The following are constructors for DynamicSOQLOrderBy.

- `DynamicSOQLOrderBy(List<String> orderByFields)`
```java
DynamicSOQLOrderBy orderBy = new DynamicSOQLOrderBy(new List<String>{'Name', 'Id'});
```

- `DynamicSOQLOrderBy(List<String> orderByFields, Boolean isDESC)`
```java
DynamicSOQLOrderBy orderBy = new DynamicSOQLOrderBy(new List<String>{'Name', 'Id'}, true);
```

- `DynamicSOQLOrderBy(List<String> orderByFields, Boolean isDESC, Boolean isNullsFirst)`
```java
DynamicSOQLOrderBy orderBy = new DynamicSOQLOrderBy(new List<String>{'Name', 'Id'}, true, true);
```

### Methods

The following are methods for DynamicSOQLOrderBy. All are instance methods.

- **fieldsApiNames** <br>
`fieldsApiNames(): Set<String>` <br>
Returns list of fields that are used in ORDER BY Statement

- **stringify** <br>
`stringify(): String` <br>
Returns ORDER BY statement like: "ORDER BY Name ASC NULLS LAST"






## DynamicSOQLGroupBy

### Constructors

The following are constructors for DynamicSOQLGroupBy.

- `DynamicSOQLGroupBy(List<String> fieldGroupByList)`
```java
DynamicSOQLGroupBy groupBy = new DynamicSOQLGroupBy(new List<String>{'StageName'});
```

### Methods

The following are methods for DynamicSOQLGroupBy. All are instance methods.

- **fieldsApiNames** <br>
`fieldsApiNames(): Set<String>` <br>
Returns list of fields that are used in GROUP BY Statement

- **withHaving** <br>
`withHaving(DynamicSOQLConditionBlock conditionBlock): DynamicSOQLGroupBy` <br>
Adds HAVING clause to the GROUP BY clause

- **stringify** <br>
`stringify(String sobjectApiName): String` <br>
Builds a GROUP BY part of SOQL string
