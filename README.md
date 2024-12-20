# Salesforce Dynamic SOQL

<span>
  <img
    alt="Salesforce Dynamic SOQL"
    src="assets/small_logo.png"
    height="28px"
  >
</span>
<a href="https://githubsfdeploy.herokuapp.com?owner=akohan91&repo=libak-salesforce-dynamic-soql&ref=main">
  <img
    alt="Deploy to Salesforce"
    src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png"
    height="28px"
  >
</a>
<a href="https://www.linkedin.com/pulse/dynamicsoql-flexible-object-oriented-solution-andrew-kohanovskij">
  <img
    alt="akohan91 | LinkedIn"
    src="https://cdn.simpleicons.org/linkedin"
    height="28px"
  >
</a>

---

Welcome to the **Salesforce Dynamic SOQL** project! This open-source library empowers Salesforce developers to write dynamic and efficient SOQL (Salesforce Object Query Language) queries in both Apex and JavaScript, enhancing productivity and code maintainability.


## 🚀 Features

- **Dynamic Query Generation**: Build SOQL queries programmatically with ease.
- **Cross-Platform Support**: Apex and JavaScript implementations available.
- **Safe and Secure**: Helps prevent SOQL injection by using binding variables.
- **Customizable**: Extend and modify the library to suit your specific needs.
- **Comprehensive API**: Easy-to-use methods for query creation, modification, and execution.


## 📖 Documentation

### Apex Reference API Guide
Learn how to use Salesforce Dynamic SOQL in your Apex code:
[Read the Apex Guide](DynamicSOQL.md)

### JavaScript Reference API Guide
Integrate Salesforce Dynamic SOQL into your JavaScript applications:
[Read the JavaScript Guide](DynamicSOQL_JS_API.md)


## 🔧 Installation

        The information is not prepared yet

## 📜 Examples

### Apex Example
```java
DynamicSOQL soql = new DynamicSOQL('Account')
    .withField('Id')
    .withField('Name')
    .withConditions(
        new DynamicSOQLConditionBlock('AND')
        .addCondition(new DynamicSOQLCondition('Name', '=', 'Some Account Name'))
    )
    .withOrderBy(new DynamicSOQLOrderBy(new List<String>{'Name', 'Id'}));

System.debug(soql.stringify());
/* The output (line breaks was added manually):
    SELECT Id,Name
    FROM Account
    WHERE (Name = 'Some Account Name')
    ORDER BY Name,Id ASC NULLS LAST
*/
```

### JavaScript Example
```javascript
const soql = new DynamicSOQL('Account')
    .withField('Id')
    .withField('Name')
    .withConditions(
        new DynamicSOQLConditionBlock('AND')
        .addCondition(new DynamicSOQLCondition('Name', '=', 'Some Account Name'))
    )
    .withOrderBy(new DynamicSOQLOrderBy(['Name', 'Id']))
    .withSubQuery(
        'Contacts',
        new DynamicSOQL('Contact')
        .withField('FirstName')
        .withField('Email')
        .withConditions(
            new DynamicSOQLConditionBlock('AND')
            .addCondition(new DynamicSOQLCondition('Email', '!=', null))
        )
    );
```


## 💡 Contributing

        The information is not prepared yet

## 📜 License
This project is licensed under the [MIT License](LICENSE).


## 📫 Contact
If you have any questions, feedback, or suggestions, feel free to reach out:
- **GitHub Issues**: [Report an issue](https://github.com/akohan91/libak-salesforce-dynamic-soql/issues)
- **Email**: akohan91@gmail.com


Thank you for using Salesforce Dynamic SOQL! We hope this library makes your development process more efficient and enjoyable. 🚀
