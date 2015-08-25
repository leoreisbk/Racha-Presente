# B2W platform API [![Build Status](https://magnum.travis-ci.com/ideaismobile/b2wkit-ios.svg?token=HgpLPTLpJGCu6X7AwRB1&branch=master)](https://magnum.travis-ci.com/ideaismobile/b2wkit-ios)

#### Document History

Date | Author | Comments
:------------- | :-----------: | ---------:
3-oct-2013 | Thiago Peres Corrêa | Document with initial specification
4-feb-2014 | Thiago Peres Corrêa | Updated method names
1-jul-2014 | Thiago Peres Corrêa | Added methods for product and department breadcrumbs, department filters. Updated product listing method with tag support. Added marketplace parameters to shipping estimate service. Added shoptime base department identifier.

----------------------

## Requests

### Catalog

##### Request Syntax
````http://www.{base url}/method?parameters=value````

##### Methods

**Departments / Subdepartments**

GET ```/mobile_departments/{id}```

Where 'id' is the menu identifier (not department identifier). This method is used for base departments and subdepartments.  

Each brand has a constant identifier that contains the base departments. In the XML, the deparment identifier is contained in the "menuId" attribute.

Brand | Constant
:-----|:--------:
Submarino | 257388
Americanas.com | 226708
Shoptime | 235028

**Department filters**
GET ```/mobile_department_filters/{id}```

Where 'id' is the department identifier.

Get filters available for a given department identifier.

**Product listing**  
GET ```/mobile_products_by_department```

Parameter | Description
:-------- | :--------
id | The group identifier. Pass multiple groups using space as separator.
tag | The tag identifier. Pass multiple tags using space as separator.
dir | Specifies how to sort the sorted entried. Valid values: asc, desc
order | Specifies sorting
offset | Integer specifying the number of products to offset from
limit | Integer specifying the number of desired products

**Available product listing sorting options**

Code | Description
:----- | :-------
itemNameSort | Name
releaseDate | Release date
salesPrice | Price
sellRankingQty | Best sellers

**Product listing applying department filters**
GET ```/mobile_products_by_department_filtered```

Parameter | Description
:-------- | :--------
menuId | The department identifier.
f_xxxxxx | The filter parameter received from mobile_department_filters

**Featured products for a specified department**  
GET ```/mobile_product_department_gallery?menuId={id}```

Get the list of featured products for a specific department identifier.

OBS: I still need to check if this works for tags aswell.

**Featured products (DEPRECATED)**  
GET ```/iphone_home_gallery```

Get the list of 10 globally featured products.

**Find Products by catalog identifiers**  
GET ```/mobile_products_by_identifiers?productIds={id}```

Get a list of products for a specified list of product identifiers. Up to 10 products per request. The response is not sorted in the order in which the identifiers were sent.

Parameter | Description
:-------- | :--------
productIds | Space separated string consisting of product identifiers

**Daily offer fallback**  
GET ```/mobile_product_daily_offer```

Get the basic product information for a product. This method is used as a fallback method when the daily offer is not available.

**Product breadcrumbs**
GET ```/especial-produto/mobile_product_breadcrumbs/{productId}/```

Where 'productId' is a product identifier. The slash after the product identifier is obligatory.

**Department breadcrumbs**
GET ```/mobile_department_breadcrumbs/{id}```

Where 'id' is a line or subline identifier.

----------------------

### Search

##### Request Syntax
````http://busca.{base url}/method?params=value````

##### Methods

**Autocomplete suggestions**  
GET ```/autocomplete.php?term={term}&origem=mobile```

Get the list of strings consisting of suggestions.

Parameter | Description
:-------- | :--------
term | String containing search term

**Search results**  
GET ```/mobile_search```

Parameter | Description
:-------- | :--------
query | CGI escaped string
sort_type | Integer indicating search result sorting
page | Integer indicating the page number
results_per_page | Integer indicating the number of desired results per page

**Available search result sorting codes**

Code | Description
:-----: | :-------
0 | Relevance
1 | Price - descending
2 | Price - ascending
3 | Name - ascending
4 | Name - descending
6 | Best sellers

### Estimate Shipping Cost (Freight)

GET ```http://carrinho.{base url}/checkout/freightService.xhtml```

For marketplace products that have several sellers, you have to make separate requests for each seller and you cannot make these request concurrently.

Parameter | Description
:-------- | :--------
codItemFusion | Product's SKU number
postalCode | Destination postal code
storeId | The marketplace seller identifier
