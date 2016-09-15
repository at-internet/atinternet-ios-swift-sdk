/*
This SDK is licensed under the MIT license (MIT)
Copyright (c) 2015- Applied Technologies Internet SAS (registration number B 403 261 258 - Trade and Companies Register of Bordeaux – France)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/





//
//  Product.swift
//  Tracker
//

import UIKit

public class Product : BusinessObject {
    
    /// Actions
    public enum Action: String {
        case View = "view"
    }
    
    /// Product identifier
    public var productId: String = ""
    
    /// First Product category
    public var category1: String?
    
    // Second Product category
    public var category2: String?
    
    // Third Product category
    public var category3: String?
    
    // Fourth Product category
    public var category4: String?
    
    // Fifth Product category
    public var category5: String?
    
    // Sixth Product category
    public var category6: String?
    
    /// Product quantity
    public var quantity: Int?
    
    /// Product unit price with tax
    public var unitPriceTaxIncluded: Double?
    
    /// Product unit price without tax
    public var unitPriceTaxFree: Double?
    
    /// Discount value with tax
    public var discountTaxIncluded: Double?
    
    /// Discount value without tax
    public var discountTaxFree: Double?
    
    /// Promotional code
    public var promotionalCode: String?
    
    /// Action
    public var action: Action = Action.View
    
    /// Set parameters in buffer
    override func setEvent() {
        tracker = tracker.setParam("type", value: "pdt")
        
        let option = ParamOption()
        option.append = true
        option.encode = true
        option.separator = "|"
        _ = tracker.setParam("pdtl", value: buildProductName(), options: option)
    }
    
    //MARK: Screen name building
    func buildProductName() -> String {
        var productName = category1 == nil ? "" : category1! + "::"
        productName = category2 ==  nil ? productName : productName + category2! + "::"
        productName = category3 ==  nil ? productName : productName + category3! + "::"
        productName = category4 ==  nil ? productName : productName + category4! + "::"
        productName = category5 ==  nil ? productName : productName + category5! + "::"
        productName = category6 ==  nil ? productName : productName + category6! + "::"
        productName += productId
        
        return productName
    }
    
    /**
    Send publisher view hit
    */
    public func sendView() {
        self.action = Action.View
        self.tracker.dispatcher.dispatch([self])
    }
}

public class Products {
    
    /// Cart instance
    var cart: Cart!
    
    /// Tracker instance
    var tracker: Tracker!
    
    /**
    CartProducts initializer
    - parameter cart: the cart instance
    - returns: CartProducts instance
    */
    init(cart: Cart) {
        self.cart = cart
    }
    
    /**
    Screens initializer
    - parameter tracker: the tracker instance
    - returns: Screens instance
    */
    init(tracker: Tracker) {
        self.tracker = tracker
    }
    
    /**
    Add a product
    - parameter product: a product instance
    - returns: the product
    */
    public func add(_ product: Product) -> Product {
        if(cart != nil) {
            cart.productList[product.productId] = product
        } else {
            tracker.businessObjects[product.id] = product
        }
        
        return product
    }
    
    /**
    Add a product
    - parameter productId: the product identifier
    - returns: the product
    */
    public func add(_ productId: String) -> Product {
        let product = Product(tracker: cart != nil ? cart.tracker : tracker)
        product.productId = productId
        
        if(cart != nil) {
            cart.productList[productId] = product
        } else {
            tracker.businessObjects[product.id] = product
        }
        
        return product
    }
    
    /**
    Add a product
    - parameter category1: category1 label
    - parameter productId: the product identifier
    - returns: the product
    */
    public func add(_ productId: String, category1: String) -> Product {
        let pdt = add(productId)
        pdt.category1 = category1
        return pdt
    }
    
    /**
    Add a product
    - parameter category1: category1 label
    - parameter category2: category2 label
    - parameter productId: the product identifier
    - returns: the product
    */
    public func add(_ productId: String, category1: String, category2: String) -> Product {
        let pdt = add(productId)
        pdt.category1 = category1
        pdt.category2 = category2
        return pdt
    }
    
    /**
    Add a product
    - parameter category1: category1 label
    - parameter category2: category2 label
    - parameter category3: category3 label
    - parameter productId: the product identifier
    - returns: the product
    */
    public func add(_ productId: String, category1: String, category2: String, category3: String) -> Product {
        let pdt = add(productId)
        pdt.category1 = category1
        pdt.category2 = category2
        pdt.category3 = category3
        return pdt
    }
    
    /**
    Add a product
    - parameter category1: category1 label
    - parameter category2: category2 label
    - parameter category3: category3 label
    - parameter category4: category4 label
    - parameter productId: the product identifier
    - returns: the product
    */
    public func add(_ productId: String, category1: String, category2: String, category3: String, category4: String) -> Product {
        let pdt = add(productId)
        pdt.category1 = category1
        pdt.category2 = category2
        pdt.category3 = category3
        pdt.category4 = category4
        return pdt
    }
    
    /**
    Add a product
    - parameter category1: category1 label
    - parameter category2: category2 label
    - parameter category3: category3 label
    - parameter category4: category4 label
    - parameter category5: category5 label
    - parameter productId: the product identifier
    - returns: the product
    */
    public func add(_ productId: String, category1: String, category2: String, category3: String, category4: String, category5: String) -> Product {
        let pdt = add(productId)
        pdt.category1 = category1
        pdt.category2 = category2
        pdt.category3 = category3
        pdt.category4 = category4
        pdt.category5 = category5
        return pdt
    }
    
    /**
    Add a product
    - parameter category1: category1 label
    - parameter category2: category2 label
    - parameter category3: category3 label
    - parameter category4: category4 label
    - parameter category5: category5 label
    - parameter category6: category6 label
    - parameter productId: the product identifier
    - returns: the product
    */
    public func add(_ productId: String, category1: String, category2: String, category3: String, category4: String, category5: String, category6: String) -> Product {
        let pdt = add(productId)
        pdt.category1 = category1
        pdt.category2 = category2
        pdt.category3 = category3
        pdt.category4 = category4
        pdt.category5 = category5
        pdt.category6 = category6
        return pdt
    }
    
    /**
    Remove a product
    - parameter productId: the product identifier
    */
    public func remove(_ productId: String) {
        if(cart != nil) {
            cart.productList.removeValue(forKey: productId)
        } else {
            for(_,value) in self.tracker.businessObjects {
                if (value is Product && (value as! Product).productId == productId) {
                    self.tracker.businessObjects.removeValue(forKey: value.id)
                    break
                }
            }
        }
    }
    
    /**
    Remove all the products
    */
    public func removeAll() {
        if(cart != nil) {
            cart.productList.removeAll(keepingCapacity: false)
        } else {
            for(_,value) in self.tracker.businessObjects {
                if (value is Product) {
                    self.tracker.businessObjects.removeValue(forKey: value.id)
                }
            }
        }
    }
    
    /**
    Send products views hits
    */
    public func sendViews() {
        var impressions = [BusinessObject]()
        
        for(_,object) in self.tracker.businessObjects {
            if(object is Product) {
                impressions.append(object)
            }
        }
        
        if(impressions.count > 0) {
            self.tracker.dispatcher.dispatch(impressions)
        }
    }
}
