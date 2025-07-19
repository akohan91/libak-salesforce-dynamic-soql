# Table of content

- [Table of content](#table-of-content)
- [Intro](#intro)
- [Quick Start](#quick-start)
  - [Build a regular query](#build-a-regular-query)
  - [Build an aggregated query](#build-an-aggregated-query)
- [Reference Guide](#reference-guide)
  - [libak_DynamicSOQL](#dynamicsoql)
    - [Constructor](#constructor)
    - [Methods](#methods)
  - [libak_DynamicSOQLFunction](#dynamicsoqlfunction)
    - [Constructor](#constructor-1)
  - [libak_DynamicSOQLConditionBlock](#dynamicsoqlconditionblock)
    - [Constructor](#constructor-2)
    - [Methods](#methods-1)
  - [libak_DynamicSOQLCondition](#dynamicsoqlcondition)
    - [Constructors](#constructors)
  - [libak_DynamicSOQLOrderBy](#dynamicsoqlorderby)
    - [Constructors](#constructors-1)
  - [libak_DynamicSOQLGroupBy](#dynamicsoqlgroupby)
    - [Constructors](#constructors-2)
    - [Methods](#methods-2)

# Intro

libak_DynamicSOQL JavaScript API is almost full mirror of Apex version and allows you to build the JSON representation of your query and then send it to the backend to process. This means you can build your query on the frontend and then process it on the backend, providing a seamless and efficient data retrieval solution.

It also enables you to build your query granularly, meaning you can prepare different parts of the query separately. For example, you can use the libak_DynamicSOQLConditionBlock and libak_DynamicSOQLCondition objects to prepare the JSON representation of your filters, and then build the WHERE clause on the backend.


The library is built in Object Oriented style and contains the next classes:

- **libak_DynamicSOQL** - the main class that represents SOQL.
- **libak_DynamicSOQLCondition** - represents the part of 'WHERE' clause in a base format like `<FieldName> <operator> <value>'`.
- **libak_DynamicSOQLConditionBlock** - used to combine **libak_DynamicSOQLCondition** or nested **libak_DynamicSOQLConditionBlock** and allows to build logical bloks with `OR | AND` keywords.
- **libak_DynamicSOQLFunction** - represent SOQL Functions, for example: `COUNT(Id) alias`.
- **libak_DynamicSOQLGroupBy** - represent `GROUP BY` clause and allows to build Aggregated Query.
- **libak_DynamicSOQLOrderBy** - represent `ORDER BY` clause.

# Quick Start

## Build a regular query

```javascript
const soql = new libak_DynamicSOQL('Account')
    .withField('Id')
    .withField('Name')
    .withConditions(
        new libak_DynamicSOQLConditionBlock('AND')
        .addCondition(new libak_DynamicSOQLCondition('Name', '=', 'Some Account Name'))
    )
    .withOrderBy(new libak_DynamicSOQLOrderBy(['Name', 'Id']))
    .withSubQuery(
        'Contacts',
        new libak_DynamicSOQL('Contact')
        .withField('FirstName')
        .withField('Email')
        .withConditions(
            new libak_DynamicSOQLConditionBlock('AND')
            .addCondition(new libak_DynamicSOQLCondition('Email', '!=', null))
        )
    );
```

## Build an aggregated query

```javascript
const soql = new libak_DynamicSOQL('Opportunity')
    .withField('StageName')
    .withFunction(new libak_DynamicSOQLFunction('SUM', 'Amount', 'amount'))
    .withFunction(new libak_DynamicSOQLFunction('COUNT', 'Id', 'oppCount'))
    .withFunction(new libak_DynamicSOQLFunction('AVG', 'Amount', 'avgAmount'))
    .withGroupBy(
        new libak_DynamicSOQLGroupBy(['StageName'])
        .withHaving(
            new libak_DynamicSOQLConditionBlock('AND')
            .addCondition(new libak_DynamicSOQLCondition(
                new libak_DynamicSOQLFunction('SUM','Amount'), '>', 190)
            )
        )
    );
```


# Reference Guide

## libak_DynamicSOQL

### Constructor

- `libak_DynamicSOQL(sObjectName)`

    **Params:**
    - sObjectName : { String } - Api name of Sobject.

```javascript
const soql = new libak_DynamicSOQL('Account');
```

### Methods

The following are methods for libak_DynamicSOQL. All are instance methods.

- **withField:** adds a field to SELECT statement <br>
`withField(fieldName): libak_DynamicSOQL` <br>

    **Params:**
    - fieldName : { String } - Api name of Sobject Field.
```javascript
new libak_DynamicSOQL('Contact')
.withField('Id')
.withField('Account.Name')
.withField('OwnerId')
```

- **withFunction:** Adds a function to SELECT statement like "COUNT(Id) recordsCount" <br>
`withFunction(function): libak_DynamicSOQL` <br>
    **Params:**
    - function : { libak_DynamicSOQLFunction } - [libak_DynamicSOQLFunction](#dynamicsoqlfunction) object from JS api.
```javascript
new libak_DynamicSOQL('Account')
.withFunction(new libak_DynamicSOQLFunction('COUNT', ''));
```

- **withSubQuery:** Adds a subquery <br>
`withSubQuery(relationshipName,  subQuery): libak_DynamicSOQL` <br>
    **Params:**
    - relationshipName : { String } - Relationship name of Sobject.
    - subQuery : { libak_DynamicSOQL } - [libak_DynamicSOQL](#dynamicsoqlfunction).

```javascript
new libak_DynamicSOQL('Account')
.withField('Name')
.withSubQuery(
    'Contacts',
    new libak_DynamicSOQL('Contact')
        .withField('Id')
)
```

- **withConditions:** adds a condition block to the query<br>
`withConditions(conditionBlock): libak_DynamicSOQL` <br>
    **Params:**
    - conditionBlock : { libak_DynamicSOQLConditionBlock } - [libak_DynamicSOQLConditionBlock](#dynamicsoqlconditionblock) object from JS api.

```javascript
new libak_DynamicSOQL('Account')
.withField('Id')
.withConditions(
    new libak_DynamicSOQLConditionBlock('AND')
    .addCondition(new libak_DynamicSOQLCondition('Name', '=', 'Test'))
    .addCondition(new libak_DynamicSOQLCondition('CreatedDate', '<', new Date()))
)
```

- **withGroupBy:** Adds a GROUP BY statement to the query<br>
`withGroupBy(libak_DynamicSOQLGroupBy groupBy): libak_DynamicSOQL` <br>
    **Params:**
    - groupBy : { libak_DynamicSOQLGroupBy } - [libak_DynamicSOQLGroupBy](#dynamicsoqlgroupby) object from JS api.

```javascript
new libak_DynamicSOQL('Opportunity')
.withField('StageName')
.withFunction(new libak_DynamicSOQLFunction('SUM', 'Amount', 'amount'))
.withGroupBy(
    new libak_DynamicSOQLGroupBy(['StageName'])
    .withHaving(
        new libak_DynamicSOQLConditionBlock('AND')
        .addCondition(new libak_DynamicSOQLCondition(
            new libak_DynamicSOQLFunction('SUM','Amount'), '>', 190)
        )
    )
)
```

- **withOrderBy:** adds the ORDER BY statement to the query<br>
`withOrderBy(orderBy): libak_DynamicSOQL` <br>
    **Params:**
    - orderBy : { libak_DynamicSOQLOrderBy } - [libak_DynamicSOQLOrderBy](#dynamicsoqlorderby) object from JS api.

```javascript
new libak_DynamicSOQL('Account')
.withField('Name')
.withOrderBy(new libak_DynamicSOQLOrderBy(['Name']))
```

- **withOffset:** adds OFFSET statement to SOQL<br>
`withOffset(offsetNumber): libak_DynamicSOQL` <br>

    **Params:**
    - offsetNumber : { Number }

```javascript
new libak_DynamicSOQL('Account')
.withField('Id')
.withOffset(0)
.withLimit(10)
```

- **withLimit:** adds LIMIT statement to SOQL<br>
`withLimit(limitNumber): libak_DynamicSOQL` <br>
    **Params:**
    - limitNumber : { Number }

```javascript
new libak_DynamicSOQL('Account')
.withField('Id')
.withOffset(0)
.withLimit(10)
```

## libak_DynamicSOQLFunction

### Constructor

- `libak_DynamicSOQLFunction(functionName, fieldName, alias)`
    **Params:**
    - functionName : { String }
    - fieldName : { String }
    - alias : { String }

```javascript
const soqlFunction = new libak_DynamicSOQLFunction('COUNT', 'Id', 'recordsCount');
```

## libak_DynamicSOQLConditionBlock

### Constructor


- `libak_DynamicSOQLConditionBlock(operator)`
    **Params:**
    - operator : { String } - Could be `"AND|OR"`

```javascript
const conditionBlock = new libak_DynamicSOQLConditionBlock('AND')
```

### Methods

The following are methods for libak_DynamicSOQL. All are instance methods.

- **addCondition:** adds a condition to the current block<br>
`addCondition(condition): libak_DynamicSOQLConditionBlock` <br>
    **Params:**
    - condition : { libak_DynamicSOQLCondition } - [libak_DynamicSOQLCondition](#dynamicsoqlcondition) object from JS api.

```javascript
const conditionBlock = new libak_DynamicSOQLConditionBlock('AND')
.addCondition(new libak_DynamicSOQLCondition('Name', '=', 'Test_1'));
```

- **addConditionBlock:** adds new condition block that will be added to the current one. It allow to build complex conditions like `(condition OR condition) AND condition`<br>
`addConditionBlock(conditionBlock): libak_DynamicSOQLConditionBlock` <br>
    **Params:**
    - conditionBlock : { libak_DynamicSOQLConditionBlock } - [libak_DynamicSOQLConditionBlock](#dynamicsoqlconditionblock) object from JS api.

```javascript
const conditionBlock = new libak_DynamicSOQLConditionBlock('AND')
.addCondition(new libak_DynamicSOQLCondition('Name', '=', 'Test1'))
.addConditionBlock(
    new libak_DynamicSOQLConditionBlock('OR')
    .addCondition(new libak_DynamicSOQLCondition('Phone', '=', '12345'))
    .addCondition(new libak_DynamicSOQLCondition('Phone', '=', '123456'))
);
```

- **switchOperator** Changes the operator. Could be either `"OR|AND"`<br>
`switchOperator(operator): libak_DynamicSOQLConditionBlock`
    **Params:**
    - operator : { String }

```javascript
const conditionBlock = new libak_DynamicSOQLConditionBlock('AND')
conditionBlock.switchOperator('OR');
```

## libak_DynamicSOQLCondition

### Constructors

- `libak_DynamicSOQLCondition(fieldName, operator, value)`
    **Params:**
    - fieldName : { String } - Sobject field api name
    - operator : { String } - SOQL condition operators like `=|!=|<|<=|>|>=|LIKE|IN|NOT IN|INCLUDES|EXCLUDES`
    - value : { Any } - value for condition. It could be any possible values like primitives, arrays of primitives or another libak_DynamicSOQL

```javascript
const booleanCondition  = new libak_DynamicSOQLCondition('isActive', '=', true);
const numberCondition   = new libak_DynamicSOQLCondition('Amount', '>=', 100);
const dateCondition     = new libak_DynamicSOQLCondition('CreatedDate', '>=', new Date());
const functionCondition = new libak_DynamicSOQLCondition(new libak_DynamicSOQLFunction('COUNT', 'Id'), '>', 10);
const stringCondition   = new libak_DynamicSOQLCondition('Name', '=', "It's a string");
const arrayCondition    = new libak_DynamicSOQLCondition('Name', 'IN', ['It\'s a string', 'It\'s another string']);
const soqlAsCondition   = new libak_DynamicSOQLCondition('AccountId', 'IN',
    new libak_DynamicSOQL('Account')
    .withField('Id')
    .withConditions(
        new libak_DynamicSOQLConditionBlock('AND')
        .addCondition(new libak_DynamicSOQLCondition('Industry', '=', 'Government'))
    )
);
```

## libak_DynamicSOQLOrderBy

### Constructors

- `libak_DynamicSOQLOrderBy(List<String> orderByFields, Boolean isDESC, Boolean isNullsFirst)`
    **Params:**
    - orderByFields : { String[] } - Sobject field api names
    - isDESC : { Boolean } - flag to set ordering direction.
    - isNullsFirst : { Boolean } - flag to set ordering of nulls

```javascript
const orderBy = new libak_DynamicSOQLOrderBy(['Name', 'Id'], true, true);
```

## libak_DynamicSOQLGroupBy

### Constructors

The following are constructors for libak_DynamicSOQL.

- `libak_DynamicSOQLGroupBy(List<String> fieldGroupByList)`
    **Params:**
    - orderByFields : { String[] } - Sobject field api names
```javascript
const groupBy = new libak_DynamicSOQLGroupBy(['StageName']);
```

### Methods

The following are methods for libak_DynamicSOQL. All are instance methods.

- **withHaving:** adds HAVING clause to the GROUP BY clause<br>
`withHaving(libak_DynamicSOQLConditionBlock conditionBlock): libak_DynamicSOQLGroupBy`
    **Params:**
    - conditionBlock : { libak_DynamicSOQLConditionBlock } - [libak_DynamicSOQLConditionBlock](#dynamicsoqlconditionblock) object from JS api.

```javascript
const groupBy = new libak_DynamicSOQLGroupBy(['Name'])
.withHaving(
    new libak_DynamicSOQLConditionBlock('AND')
    .addCondition(new libak_DynamicSOQLCondition(new libak_DynamicSOQLFunction('COUNT', 'Name'), '>', 10))
);
```