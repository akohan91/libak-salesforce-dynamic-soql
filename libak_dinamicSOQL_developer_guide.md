# Libak Dynamic SOQL Developer Guide

## Table of Contents
- [Introduction](#introduction)
- [Basic Concepts](#basic-concepts)
- [Examples](#examples)
- [Advanced Usage](#advanced-usage)

## Introduction

Libak Dynamic SOQL is a utility library that simplifies creating and working with dynamic SOQL queries in Salesforce. It provides a fluent, type-safe interface for constructing complex SOQL queries programmatically, reducing the risk of runtime errors and improving code readability.

## Basic Concepts

### Factory Pattern

The library uses a factory pattern to create SOQL builders. First, initialize the factory with a field path constructor:

```apex
// Initialize the factory in a utility class
public with sharing class Soql {
    public static libak_DynamicSOQL.Factory factory = new libak_DynamicSOQL.Factory(
        new FieldPathConstructor()
    );
}
```

### Query Builder

The core of the library is using the factory to build SOQL queries step by step:

```apex
String soqlString = Soql.factory.build(Account.SObjectType)
    .withField('Id')
    .withField('Name')
    .withConditions(
        new libak_DynamicSOQLConditionBlock('AND')
        .addCondition(new libak_DynamicSOQLCondition('Name', 'LIKE', '%Inc%'))
    )
    .withOrderBy(new libak_DynamicSOQLOrderBy(new List<String>{'Name'}))
    .stringify();
```

### Condition Builder

For complex WHERE clauses, the library provides condition blocks:

```apex
libak_DynamicSOQLConditionBlock conditions = new libak_DynamicSOQLConditionBlock('AND')
    .addCondition(new libak_DynamicSOQLCondition('CreatedDate', '>=', Datetime.now().addDays(-7)))
    .addCondition(new libak_DynamicSOQLCondition('AnnualRevenue', '>', 1000000));

String soqlString = Soql.factory.build(Account.SObjectType)
    .withField('Id')
    .withField('Name')
    .withConditions(conditions)
    .stringify();
```

## Examples

### Basic Query

```apex
String soqlString = Soql.factory.build(Account.SObjectType)
    .withField('Id')
    .withField('Name')
    .withField('Phone')
    .withConditions(
        new libak_DynamicSOQLConditionBlock('AND')
        .addCondition(new libak_DynamicSOQLCondition('Name', 'LIKE', '%Inc%'))
    )
    .stringify();

List<Account> accounts = Database.query(soqlString);
```

### Relationship Queries

```apex
String soqlString = Soql.factory.build(Contact.SObjectType)
    .withField('Id')
    .withField('FirstName')
    .withField('LastName')
    .withField('Email')
    .withField('Account.Name')
    .withField('Account.Industry')
    .withConditions(
        new libak_DynamicSOQLConditionBlock('AND')
        .addCondition(new libak_DynamicSOQLCondition('Account.Industry', '=', 'Technology'))
    )
    .stringify();

List<Contact> contacts = Database.query(soqlString);
```

### Subqueries

```apex
String soqlString = Soql.factory.build(Account.SObjectType)
    .withField('Id')
    .withField('Name')
    .withSubQuery(
        'Contacts',
        Soql.factory.build(Contact.SObjectType)
        .withField('FirstName')
        .withField('Email')
        .withConditions(
            new libak_DynamicSOQLConditionBlock('AND')
            .addCondition(new libak_DynamicSOQLCondition('Email', '!=', (String)null))
        )
    )
    .stringify();

List<Account> accountsWithContacts = Database.query(soqlString);
```

### Aggregate Queries

```apex
String soqlString = Soql.factory.build(Opportunity.SObjectType)
    .withField('StageName')
    .withFunction(new libak_DynamicSOQLFunction('SUM', 'Amount', 'amount'))
    .withFunction(new libak_DynamicSOQLFunction('COUNT', 'Id', 'oppCount'))
    .withGroupBy(
        new libak_DynamicSOQLGroupBy(new List<String>{'StageName'})
        .withHaving(
            new libak_DynamicSOQLConditionBlock('AND')
            .addCondition(new libak_DynamicSOQLCondition(
                new libak_DynamicSOQLFunction('SUM','Amount'), '>', 10000)
            )
        )
    )
    .stringify();

List<AggregateResult> results = Database.query(soqlString);
```

## Advanced Usage

### Dynamic Field Selection

```apex
List<String> fieldsToQuery = new List<String>();
Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Account.fields.getMap();

for(String fieldName : fieldMap.keySet()) {
    Schema.DescribeFieldResult describe = fieldMap.get(fieldName).getDescribe();
    if(describe.isAccessible()) {
        fieldsToQuery.add(fieldName);
    }
}

libak_DynamicSOQL builder = Soql.factory.build(Account.SObjectType);
for(String field : fieldsToQuery) {
    builder.withField(field);
}

String soqlString = builder.stringify();
```

### Complex Nested Conditions

```apex
libak_DynamicSOQLConditionBlock mainCondition = new libak_DynamicSOQLConditionBlock('AND')
    .addCondition(new libak_DynamicSOQLCondition('Industry', '=', 'Technology'))
    .addConditionBlock(
        new libak_DynamicSOQLConditionBlock('OR')
        .addCondition(new libak_DynamicSOQLCondition('AnnualRevenue', '>', 1000000))
        .addCondition(new libak_DynamicSOQLCondition('NumberOfEmployees', '>', 500))
    );

String soqlString = Soql.factory.build(Account.SObjectType)
    .withField('Id')
    .withField('Name')
    .withConditions(mainCondition)
    .stringify();
```

### Field Path Management

The library handles field paths automatically through the `SobjectFieldPath` class, which validates field existence and relationships:

```apex
SobjectFieldPath path = new SobjectFieldPath('Account', 'Owner.Profile.Name');
Schema.DescribeFieldResult fieldDescribe = path.targetFieldDescribe();
```