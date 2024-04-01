public with sharing class ProductWizardController {
    @TestVisible
    private static String STANDARD_PRICEBOOK_NAME = 'Standard Price Book';
	private static final String OPP_KEY_PREFIX = Schema.SObjectType.Opportunity.getKeyPrefix();
    private static final String QUOTE_KEY_PREFIX = Schema.SObjectType.Quote.getKeyPrefix();
    private static final String COUNTRY_IRELAND = 'Ireland';
    
    /*@AuraEnabled
    public static List <CustomPayload> getOpportunityProductsByRoom(String roomId) {

        List <CustomPayload> response = new List <CustomPayload> ();
        Boolean isQuote = false;
        Boolean isOpportunity = false;

        for(Room__c r : [SELECT Id, Quote__c, Opportunity__c FROM Room__c WHERE Id =: roomId]) {

            if(!String.isBlank(r.Quote__c)) {

                isQuote = true;
            }
            else if(!String.isBlank(r.Opportunity__c)) {

                isOpportunity = true;
            }
        }

        if(isQuote) {

            for(Room_Item__c ri : [SELECT Id, Sequence__c, Parent_ID__c, Relationship_Id__c, Relationship_Type__c, Wizard_ID__c, 
                                   Quantity__c, Total_Price__c, Room__c, Opportunity_Product__c, Opportunity_Product__r.OpportunityId, 
                                   Quote_Line_Item__r.Wizard_ID__c,Quote_Line_Item__r.PricebookEntryId, Quote_Line_Item__r.Product2Id, Quote_Line_Item__r.Quantity, 
                                   Quote_Line_Item__r.Product2.Description, Quote_Line_Item__r.Product2.ProductCode, Quote_Line_Item__r.Product2.Name, 
                                   Quote_Line_Item__r.UnitPrice, Quote_Line_Item__r.Sales_Price_Discount__c, Quote_Line_Item__r.CurrencyIsoCode, Quote_Line_Item__r.TotalPrice, 
                                   Quote_Line_Item__r.QuoteId, Quote_Line_Item__c, Quote_Line_Item__r.Product2.images__c, Quote_Line_Item__r.ListPrice,  Quote_Line_Item__r.PricebookEntry.Current_Cost__c,
                                   Quote_Line_Item__r.Manual_Update_Sales_Price__c 
                                   FROM Room_Item__c WHERE Room__c =: roomId ORDER BY Sequence__c ASC]) {

                CustomPayload payload = new CustomPayload();
                payload.UniqueId = ri.Wizard_ID__c;
                payload.OpportunityId = ri.Opportunity_Product__r.OpportunityId;
                payload.OpportunitylineItemId = ri.Opportunity_Product__c;
                payload.PricebookEntryId = ri.Quote_Line_Item__r.PricebookEntryId;
                payload.Product2Id = ri.Quote_Line_Item__r.Product2Id;
                payload.Quantity = Integer.valueOf(ri.Quantity__c);
                payload.PreviousQuantity = Integer.valueOf(ri.Quantity__c);
                payload.Description = ri.Quote_Line_Item__r.Product2.Description;
                payload.ProductCode = ri.Quote_Line_Item__r.Product2.ProductCode;
                payload.ProductName = ri.Quote_Line_Item__r.Product2.Name;
                payload.Name = ri.Quote_Line_Item__r.Product2.Name;
                payload.UnitPrice = ri.Quote_Line_Item__r.UnitPrice;
                payload.SalesPriceDiscount = setScale(ri.Quote_Line_Item__r.Sales_Price_Discount__c, 2);
                payload.CurrencyIsoCode = ri.Quote_Line_Item__r.CurrencyIsoCode;
                payload.ListPrice = ri.Quote_Line_Item__r.ListPrice; 
                payload.TotalPrice = returnZeroIfNull(ri.Quote_Line_Item__r.UnitPrice) * returnZeroIfNull(payload.Quantity);
                payload.RoomId = roomId;
                payload.RoomItemId = ri.Id;
                payload.QuoteId = ri.Quote_Line_Item__r.QuoteId;
                payload.QuoteLineItemId = ri.Quote_Line_Item__c;
                payload.ImageUrl = ri.Quote_Line_Item__r.Product2.images__c;
                payload.ParentId = ri.Parent_ID__c;
                payload.RelationshipType = ri.Relationship_Type__c;
                payload.RelationshipId = ri.Relationship_Id__c;
                payload.Checked = true;
                payload.ToDelete = false;
                payload.Sequence = ri.Sequence__c;
                payload.PriceLocked = ri.Quote_Line_Item__r.Manual_Update_Sales_Price__c;
                                       
                if(QuoteLineItem.Margin__c.getDescribe().isAccessible()){
                    payload.Margin = calculateMargin(ri.Quote_Line_Item__r.UnitPrice, ri.Quote_Line_Item__r.PricebookEntry.Current_Cost__c);
                }               

                response.add(payload);
            }
        }
        else if(isOpportunity) {
            for(Room_Item__c ri : [SELECT Id, Sequence__c, Parent_ID__c, Relationship_Id__c, Relationship_Type__c, Wizard_ID__c, Quantity__c, 
                                   Total_Price__c, Room__c, Quote_Line_Item__r.QuoteId, Quote_Line_Item__c, Opportunity_Product__c, 
                                   Opportunity_Product__r.OpportunityId, Opportunity_Product__r.CurrencyIsoCode, Opportunity_Product__r.Product2.Name, 
                                   Opportunity_Product__r.Product2.ProductCode, Opportunity_Product__r.Product2.Description, Opportunity_Product__r.Wizard_ID__C, 
                                   Opportunity_Product__r.Quantity, Opportunity_Product__r.Sales_Price_Discount__c, Opportunity_Product__r.UnitPrice, Opportunity_Product__r.TotalPrice, 
                                   Opportunity_Product__r.PricebookEntryId, Opportunity_Product__r.Product2Id, Opportunity_Product__r.Product2.images__c, Opportunity_Product__r.PricebookEntry.Current_Cost__c,
                                   Opportunity_Product__r.ListPrice, Opportunity_Product__r.Manual_Update_Sales_Price__c FROM Room_Item__c WHERE Room__c =: roomId ORDER BY Sequence__c ASC]) {
                CustomPayload payload = new CustomPayload();
                payload.UniqueId = ri.Wizard_ID__c;
                payload.OpportunityId = ri.Opportunity_Product__r.OpportunityId;
                payload.OpportunitylineItemId = ri.Opportunity_Product__c;
                payload.PricebookEntryId = ri.Opportunity_Product__r.PricebookEntryId;
                payload.Product2Id = ri.Opportunity_Product__r.Product2Id;
                payload.Quantity = Integer.valueOf(ri.Quantity__c);
                payload.PreviousQuantity = Integer.valueOf(ri.Quantity__c);
                payload.Description = ri.Opportunity_Product__r.Product2.Description;
                payload.ProductCode = ri.Opportunity_Product__r.Product2.ProductCode;
                payload.ProductName = ri.Opportunity_Product__r.Product2.Name;
                payload.Name = ri.Opportunity_Product__r.Product2.Name;
                payload.UnitPrice = ri.Opportunity_Product__r.UnitPrice;
                payload.SalesPriceDiscount = setScale(ri.Opportunity_Product__r.Sales_Price_Discount__c, 2);
                payload.CurrencyIsoCode = ri.Opportunity_Product__r.CurrencyIsoCode;
                payload.ListPrice = ri.Opportunity_Product__r.ListPrice;
                payload.TotalPrice = returnZeroIfNull(ri.Opportunity_Product__r.UnitPrice) * returnZeroIfNull(payload.Quantity);
                payload.RoomId = roomId;
                payload.RoomItemId = ri.Id;
                payload.QuoteId = ri.Quote_Line_Item__r.QuoteId;
                payload.QuoteLineItemId = ri.Quote_Line_Item__c;
                payload.ImageUrl = ri.Opportunity_Product__r.Product2.images__c;
                payload.ParentId = ri.Parent_ID__c;
                payload.RelationshipType = ri.Relationship_Type__c;
                payload.RelationshipId = ri.Relationship_Id__c;
                payload.Checked = true;
                payload.ToDelete = false;
                payload.Sequence = ri.Sequence__c;
				payload.PriceLocked = ri.Opportunity_Product__r.Manual_Update_Sales_Price__c;
                                       
                if(OpportunityLineItem.Margin__c.getDescribe().isAccessible()){
                    payload.Margin = calculateMargin(ri.Opportunity_Product__r.UnitPrice, ri.Opportunity_Product__r.PricebookEntry.Current_Cost__c); 
                }
                                       
                response.add(payload);
            }
        }

        return response;
    }
    
    private static Decimal setScale(Decimal value, integer scale){
        if(value != null){
            return value.setScale(scale);
        }
        
        return value;
    }

    private static Decimal calculateMargin(Decimal unitPrice, Decimal currentCost){
        if(unitPrice != null && currentCost != null && unitPrice != 0){
            Decimal diff = unitPrice - currentCost;
            
            return ((diff/unitPrice) * 100).setScale(2);
        }
        
        return null;
    }
    
    private static Decimal calculateDiscount(Decimal unitPrice, Decimal listPrice){
        if(unitPrice != null && listPrice != null && listPrice != 0){
            Decimal diff = listPrice - unitPrice;
            
            return ((diff/listPrice) * 100).setScale(2);
        }
        
        return null;
    }
    
    private static Decimal returnZeroIfNull(Decimal val){
        if(val != null){
            return val;
        }    
        
        return 0;
    }*/
    
    @AuraEnabled(cacheable=true)
    public static List <CustomPayload> getProducts(String recordId) {

        String currencyIsoCode = 'GBP'; //default currency code in case of null

        if(recordId.startsWith(OPP_KEY_PREFIX)) {

            for(Opportunity o : [SELECT CurrencyIsoCode FROM Opportunity WHERE Id =: recordId]) {

                currencyIsoCode = o.CurrencyIsoCode;
            }
        }
        else if(recordId.startsWith(QUOTE_KEY_PREFIX)){

            for(Quote q : [SELECT CurrencyIsoCode FROM Quote WHERE Id =: recordId]) {

                currencyIsoCode = q.CurrencyIsoCode;
            }
        }

        List <CustomPayload> response = new List <CustomPayload> ();
        
        for(PricebookEntry p : [SELECT CurrencyIsoCode, Id, IsActive, Name, Product2Id, Product2.Name, ProductCode,  
                                UnitPrice, Product2.Description,Product2.ovcMaterialGroup__c, Product2.ovcProductHierarchy__c, Product2.ovcSAPMaterialNumber__c, Product2.Plant__c, Product2.Storage__c
                                //Product2.images__c, Current_Cost__c, Product2.Classification__c, Product2.ApprovalNumber__c
                                FROM PricebookEntry WHERE Product2.IsActive = true AND Pricebook2.Name = :STANDARD_PRICEBOOK_NAME AND CurrencyIsoCode =: currencyIsoCode LIMIT 50]) {

            CustomPayload payload = new CustomPayload();
            payload.UniqueId = '';
            payload.OpportunityId = '';
            payload.OpportunitylineItemId = '';
            payload.PricebookEntryId = p.Id;
            payload.Product2Id = p.Product2Id;
            payload.Quantity = null;
            payload.Description = p.Product2.Description;
            payload.ProductCode = p.ProductCode;
            payload.ProductName = p.Product2.Name;
            payload.Name = p.Name;
            payload.ListPrice = p.UnitPrice;
            payload.UnitPrice = p.UnitPrice;
            payload.CurrencyIsoCode = p.CurrencyIsoCode;

            payload.MaterialGroup = p.Product2.ovcMaterialGroup__c;
            payload.MaterialNumber = p.Product2.ovcSAPMaterialNumber__c;
            payload.ProductHierarchy = p.Product2.ovcProductHierarchy__c;                 

            /*payload.Classification = p.Product2.Classification__c;
            payload.ApprovalNumber = p.Product2.ApprovalNumber__c;
            payload.CurrentCost = p.Current_Cost__c;
            payload.QuoteId = '';
            payload.QuoteLineItemId = '';
            payload.ImageUrl = p.Product2.images__c;*/
            payload.ToDelete = false;
            response.add(payload);
        }

        return response;
    }

    private static CustomPayload constructPayload(PricebookEntry p) {

        CustomPayload payload = new CustomPayload();
        payload.UniqueId = '';
        payload.OpportunityId = '';
        payload.OpportunitylineItemId = '';
        payload.PricebookEntryId = p.Id;
        payload.Product2Id = p.Product2Id;
        payload.Quantity = null;
        payload.Description = p.Product2.Description;
        payload.ProductCode = p.ProductCode;
        payload.ProductName = p.Product2.Name;
        payload.Name = p.Name;
        payload.ListPrice = p.UnitPrice;
        payload.UnitPrice = p.UnitPrice;
        //payload.Classification = p.Product2.Classification__c;
        //payload.ApprovalNumber = p.Product2.ApprovalNumber__c;
        payload.CurrencyIsoCode = p.CurrencyIsoCode;
        payload.QuoteId = '';
        payload.QuoteLineItemId = '';
        //payload.ImageUrl = p.Product2.images__c;
        payload.ToDelete = false;
        //payload.CurrentCost = p.Current_Cost__c;
        payload.MaterialNumber = p.Product2.ovcSAPMaterialNumber__c;
        payload.ProductHierarchy = p.Product2.ovcProductHierarchy__c;
        return payload;
    }

    @AuraEnabled(cacheable=true)
    public static List <CustomPayload> searchProducts(Map<String, String> filters, String currencyIsoCode, String price) {
        system.debug('searchProducts');
        List<CustomPayload> response = new List <CustomPayload> ();  
        String query = 'SELECT CurrencyIsoCode, Id, IsActive, Name, Product2Id, Product2.Name, Product2.ProductCode , ProductCode,  UnitPrice, Product2.Description, Product2.ovcSAPMaterialNumber__c, Product2.ovcProductHierarchy__c FROM PricebookEntry WHERE Product2.Isactive = TRUE AND CurrencyIsoCode = \'' + currencyIsoCode + '\' ';
        List<String> stringFieldsLike = new List<String>{'ProductCode'};
        List<String> stringFieldsExactMatch = new List<String>{'category__c', 'brand__c', 'range__c', 'colour__c', 'tapholes__c'};
        List<String> numberFields = new List<String>{'flowrateat02bar__c', 'flowrateat05bar__c', 'flowrateat1bar__c', 'flowrateat2bar__c', 'flowrateat3bar__c', 'flowrateat4bar__c', 'flowrateat5bar__c'};
        List<String> rangeFields = new List<String>{'productheightmm__c', 'productwidthmm__c'};
        
        // Determine if any flowrateat* selected
        boolean hasSelectedFlowRateAt = false;
        
        for(String filterName : filters.keySet()){
            if(filterName.startsWith('flowrateat')){
                hasSelectedFlowRateAt = true;
            }   
        }
        
        // Build query based on each filter
        for(String filterName : filters.keySet()){
            String filterValue = filters.get(filterName);
            
            if(filterValue != '-'){
                if(String.isBlank(filterValue)){
                    query += 'AND Product2.' + filterName + ' = null ';
                } else if(stringFieldsLike.contains(filterName)){
                    query += 'AND Product2.' + filterName + ' LIKE \'%' + filterValue + '%\' ';
                }
                /*else if(stringFieldsExactMatch.contains(filterName)){
                    query += 'AND Product2.' + filterName + '=\'' + filterValue + '\' ';
                }else if(numberFields.contains(filterName)){
                    query += 'AND Product2.' + filterName + '= '+ filterValue + ' ';
                }else if(rangeFields.contains(filterName)){
                    List<String> splitArr = filterValue.split('-');
                    Decimal min = Integer.valueOf(splitArr[0].trim());
                    Decimal max = Integer.valueOf(splitArr[1].trim());
                    
                    query += 'AND Product2.' + filterName + ' >= '+ min +' AND Product2.' + filterName + ' < ' + max + ' ';
                }else if(filterName == 'flowrate' && hasSelectedFlowRateAt){
                    query += 'AND Product2.' + filterValue + ' != null ';
                }*/
            }
        }
        
        // Add condition for price filter
        if(!String.isBlank(price)) {

            Decimal priceDecimal = Decimal.valueOf(price);

            if(priceDecimal > 0) {

                query += 'AND UnitPrice <= '+ priceDecimal +' ';
            }
        }

        //setting the query limit
        query += 'LIMIT 50';
        
        system.debug(query);

        for(PricebookEntry p : Database.query(query)) {
			system.debug(query);
            response.add(constructPayload(p));
            
            //payload.MaterialNumber = p.Product2.ovcSAPMaterialNumber__c;
            //payload.ProductHierarchy = p.Product2.ovcProductHierarchy__c;
        }

        return response;
    }

    /*@AuraEnabled
    public static List <CustomPayload> deleteProducts(List <CustomPayload> payloads, CustomPayload room) {
        List<Room_Item__c> roomItemsToDelete = new List<Room_Item__c>();
        
        for(CustomPayload payload : payloads){
            if(payload.toDelete){
                if(String.isNotBlank(payload.RoomItemId)){
                    roomItemsToDelete.add(new Room_Item__c(
                    	Id = payload.RoomItemId
                    ));
                }
            }
        }
        
        System.debug('roomItemsToDelete: ' + roomItemsToDelete);
        delete roomItemsToDelete;
        
        return new List <CustomPayload>();
    }

    @AuraEnabled
    public static Boolean deleteRoom(RoomSelectorController.CustomPayload room) {
        List<Room_Item__c> roomItems = [SELECT Id FROM Room_Item__c WHERE Room__c = :room.Id];
        delete roomItems;
        
        Room__c r = new Room__c();
        r.Id = room.id;
        delete r;

        return true;
    }

    @AuraEnabled
    public static List <CustomPayload> saveAllProducts(List <CustomPayload> payloads, CustomPayload room) {
        Map <String, OpportunityLineItem> lineItemsToInsert = new Map <String, OpportunityLineItem>();
        Map <String, QuoteLineItem> qlineItemsToInsert = new Map <String, QuoteLineItem>();
        Map <String, CustomPayload> payloadsMap = new Map <String, CustomPayload> ();
        Map <String, CustomPayload> payloadsMap2 = new Map <String, CustomPayload> ();
        List <Room_Item__c> roomItemToInsert = new List <Room_Item__c> ();

        if(!String.isBlank(room.QuoteId)) {

            Map <String, Map <String, QuoteLineItem>> qliProductMap = new Map <String, Map <String, QuoteLineItem>>();
            Set <String> qIds = new Set <String> ();

            for(CustomPayload payload : payloads) {

                qIds.add(payload.QuoteId);
            }

            for(QuoteLineItem qli : [SELECT Id, QuoteId, PricebookEntryId, Quantity, Wizard_ID__c, Product2Id FROM QuoteLineItem WHERE QuoteId =: qIds]) {

                if(qliProductMap.containsKey(qli.QuoteId)) {
       
                    qliProductMap.get(qli.QuoteId).put(qli.PricebookEntryId, qli);
                }
                else {
                 
                    Map <String, QuoteLineItem> innerMap = new Map <String, QuoteLineItem> ();
                    innerMap.put(qli.PricebookEntryId, qli);
                    qliProductMap.put(qli.QuoteId, innerMap);
                }
            }   

            for(CustomPayload payload : payloads) {

                QuoteLineItem obj = new QuoteLineItem();

                if(qliProductMap.containsKey(payload.QuoteId)) {
           
                    if(qliProductMap.get(payload.QuoteId).containsKey(payload.PricebookEntryId)) {
                
                        obj.Id = qliProductMap.get(payload.QuoteId).get(payload.PricebookEntryId).Id;
                    
                        if(qlineItemsToInsert.containsKey(payload.PricebookEntryId)) {
                        
                            obj.Quantity = qlineItemsToInsert.get(payload.PricebookEntryId).Quantity + payload.Quantity;
                            obj.Quantity = (payload.PreviousQuantity != null) ? (obj.Quantity - payload.PreviousQuantity) : obj.Quantity;
                        }
                        else {
                 
                            obj.Quantity = (qliProductMap.get(payload.QuoteId).containsKey(payload.PricebookEntryId)) ? qliProductMap.get(payload.QuoteId).get(payload.PricebookEntryId).Quantity + payload.Quantity : payload.Quantity;
                            obj.Quantity = (payload.PreviousQuantity != null) ? (obj.Quantity - payload.PreviousQuantity) : obj.Quantity;
                        }
                    }
                    else {
                   
                        obj.Quantity = payload.Quantity;
                        obj.Product2Id = payload.Product2Id;
                        obj.PricebookEntryId = payload.PricebookEntryId;
                        obj.QuoteId = payload.QuoteId;
                    }
                }
                else {
                 
                    obj.Quantity = payload.Quantity;
                    obj.Product2Id = payload.Product2Id;
                    obj.PricebookEntryId = payload.PricebookEntryId;
                    obj.QuoteId = payload.QuoteId;
                }
                
                obj.Wizard_ID__c = payload.UniqueId;
                obj.Sales_Price_Discount__c = payload.SalesPriceDiscount;
                obj.UnitPrice = payload.UnitPrice;

                if(qliProductMap.containsKey(payload.QuoteId)) {

                    if(qliProductMap.get(payload.QuoteId).containsKey(payload.PricebookEntryId)) {

                        qliProductMap.get(payload.QuoteId).get(payload.PricebookEntryId).Quantity = obj.Quantity;
                    }
                }
                
                qlineItemsToInsert.put(payload.PricebookEntryId, obj);
                payloadsMap.put(payload.UniqueId, payload);
            }
   
            if(!qlineItemsToInsert.isEmpty()) {
                
                upsert qlineItemsToInsert.values();

                for(CustomPayload payload : payloadsMap.values()) {

                    if(qlineItemsToInsert.containskey(payload.PricebookEntryId)) {

                        payload.QuoteLineItemId = qlineItemsToInsert.get(payload.PricebookEntryId).Id;
                    }

                    Room_Item__c ri = new Room_Item__c();

                        if(!String.isBlank(payload.RoomItemId)) {
                
                            ri.Id = payload.RoomItemId;
                        }
                        else {
            
                            ri.Name = payload.ProductName;
                            ri.Product_Code__c = payload.ProductCode;
                            ri.Room__c = payload.RoomId;
                            ri.Quote_Line_Item__c = qlineItemsToInsert.get(payload.PricebookEntryId).Id;
                        }
            
                        ri.Wizard_ID__c = payload.UniqueId;
                        ri.Quantity__c = payload.Quantity;

                        //relationship
                        ri.Relationship_Type__c = payload.RelationshipType;
                        ri.Relationship_Id__c = payload.RelationshipId;
                        ri.Parent_ID__c = payload.ParentId;

                        ri.Sequence__c = payload.Sequence;

                        roomItemToInsert.add(ri);

                        payloadsMap2.put(ri.Wizard_ID__c, payload);
                }

                if(!roomItemToInsert.isEmpty()) {
    
                    upsert roomItemToInsert;
    
                    for(Room_Item__c ri : roomItemToInsert) {
    
                        if(payloadsMap2.containsKey(ri.Wizard_ID__c)) {
                    
                            payloadsMap2.get(ri.Wizard_ID__c).RoomItemId = ri.Id;
                        }
                    }
                }
            }  

            return payloadsMap2.values();
        }
        else if(!String.isBlank(room.OpportunityId)) {

            Map <String, Map <String, OpportunityLineItem>> oliProductMap = new Map <String, Map <String, OpportunityLineItem>>();
            Set <String> oppIds = new Set <String> ();

            //set up map for future reference
            for(CustomPayload payload : payloads) {

                oppIds.add(payload.OpportunityId);
            }
     
            for(OpportunityLineItem oli : [SELECT Id, OpportunityId, PricebookEntryId, Quantity, Wizard_ID__c FROM OpportunityLineItem WHERE OpportunityId =: oppIds]) {

                if(oliProductMap.containsKey(oli.OpportunityId)) {

                    oliProductMap.get(oli.OpportunityId).put(oli.PricebookEntryId, oli);
                }
                else {

                    Map <String, OpportunityLineItem> innerMap = new Map <String, OpportunityLineItem> ();
                    innerMap.put(oli.PricebookEntryId, oli);
                    oliProductMap.put(oli.OpportunityId, innerMap);
                }
            }   
  
            for(CustomPayload payload : payloads) {
                
                OpportunityLineItem obj = new OpportunityLineItem();

                if(oliProductMap.containsKey(payload.OpportunityId)) {

                    if(oliProductMap.get(payload.OpportunityId).containsKey(payload.PricebookEntryId)) {

                        obj.Id = oliProductMap.get(payload.OpportunityId).get(payload.PricebookEntryId).Id;

                        if(lineItemsToInsert.containsKey(payload.PricebookEntryId)) {

                            obj.Quantity = lineItemsToInsert.get(payload.PricebookEntryId).Quantity + payload.Quantity;
                            obj.Quantity = (payload.PreviousQuantity != null) ? (obj.Quantity - payload.PreviousQuantity) : obj.Quantity;
                        }
                        else {

                            if(oliProductMap.get(payload.OpportunityId).containsKey(payload.PricebookEntryId)) {

                                obj.Quantity = oliProductMap.get(payload.OpportunityId).get(payload.PricebookEntryId).Quantity + payload.Quantity;
                            }
                            else {
                                
                                obj.Quantity = payload.Quantity;
                            }
                            obj.Quantity = (payload.PreviousQuantity != null) ? (obj.Quantity - payload.PreviousQuantity) : obj.Quantity;
                        }
                    }
                    else {

                        obj.Quantity = payload.Quantity;
                        obj.OpportunityId = payload.OpportunityId;
                        obj.PricebookEntryId = payload.PricebookEntryId;
                        obj.Product2Id = payload.Product2Id;
                    }
                }
                else {

                    obj.Quantity = payload.Quantity;
                    obj.OpportunityId = payload.OpportunityId;
                    obj.PricebookEntryId = payload.PricebookEntryId;
                    obj.Product2Id = payload.Product2Id;
                }
                
                obj.Wizard_ID__c = payload.UniqueId;
                obj.Sales_Price_Discount__c = payload.SalesPriceDiscount;
                obj.UnitPrice = payload.UnitPrice;

                if(oliProductMap.containsKey(payload.OpportunityId)) {

                    if(oliProductMap.get(payload.OpportunityId).containsKey(payload.PricebookEntryId)) {

                        oliProductMap.get(payload.OpportunityId).get(payload.PricebookEntryId).Quantity = obj.Quantity;
                    }
                }
                
                lineItemsToInsert.put(payload.PricebookEntryId, obj);
                payloadsMap.put(payload.UniqueId, payload);
            }

            if(!lineItemsToInsert.isEmpty()) {
                System.debug('lineItemsToInsert: ' + lineItemsToInsert);
                upsert lineItemsToInsert.values();

                for(CustomPayload payload : payloadsMap.values()) {

                    if(lineItemsToInsert.containskey(payload.PricebookEntryId)) {

                        payload.OpportunityLineItemId = lineItemsToInsert.get(payload.PricebookEntryId).Id;
                    }

                    Room_Item__c ri = new Room_Item__c();

                        if(!String.isBlank(payload.RoomItemId)) {
                
                            ri.Id = payload.RoomItemId;
                        }
                        else {
            
                            ri.Name = payload.ProductName;
                            ri.Product_Code__c = payload.ProductCode;
                            ri.Room__c = payload.RoomId;
                            ri.Opportunity_Product__c = lineItemsToInsert.get(payload.PricebookEntryId).Id;
                        }
            
                        ri.Wizard_ID__c = payload.UniqueId;
                        ri.Quantity__c = payload.Quantity;

                        //relationship
                        ri.Relationship_Type__c = payload.RelationshipType;
                        ri.Relationship_Id__c = payload.RelationshipId;
                        ri.Parent_ID__c = payload.ParentId;

                        ri.Sequence__c = payload.Sequence;

                        roomItemToInsert.add(ri);

                        payloadsMap2.put(ri.Wizard_ID__c, payload);
                }

                if(!roomItemToInsert.isEmpty()) {
   
                    upsert roomItemToInsert;
    
                    for(Room_Item__c ri : roomItemToInsert) {
    
                        if(payloadsMap2.containsKey(ri.Wizard_ID__c)) {
                    
                            payloadsMap2.get(ri.Wizard_ID__c).RoomItemId = ri.Id;
                        }
                    }
                }
            }   
        }

        return payloadsMap2.values();
    }

    @AuraEnabled
    public static List <CustomPayload> updateProductSequence(List <CustomPayload> payloads) {

        List <Room_Item__c> roomItemsToUpdate = new List <Room_Item__c> ();

        for(CustomPayload payload : payloads) {

            Room_Item__c ri = new Room_Item__c();
            ri.Id = payload.RoomItemId;
            ri.Sequence__c = payload.Sequence;
            roomItemsToUpdate.add(ri);
        }

        if(!roomItemsToUpdate.isEmpty()) {

            update roomItemsToUpdate;
        }

        return payloads;
    }

    @AuraEnabled
    public static Map<String, List<SObject>> checkProductRelationships(List<String> productIds, String currencyIsoCode){
        Map<String, List<SObject>> result = new Map<String, List<SObject>>();
        
        List<Product_Relationship__c> productRelationships = [SELECT Id, Relationship_Type__c, Child_Product__c, Parent_Product__c FROM Product_Relationship__c
                                                             WHERE Parent_Product__c IN :productIds AND Child_Product__r.CurrencyIsoCode =: currencyIsoCode AND Active_Relationship__c = true];
        for(Product_Relationship__c productRelationship : productRelationships){
            if(!result.containsKey(productRelationship.Parent_Product__c)){
                result.put(productRelationship.Parent_Product__c, new List<SObject>());
            }                                        
            
            result.get(productRelationship.Parent_Product__c).add(productRelationship);
        }
        
        return result;
    }
    
    @AuraEnabled
    public static List <CustomPayload> getProductRelationships(String productId, String currencyIsoCode, String parentId) {

        List <CustomPayload> response = new List <CustomPayload> ();

        //existing room item map
        //relationship type, product id, room item
        Map <String, Map <String, Room_Item__c>> roomItemMap = new Map <String, Map <String, Room_Item__c>> ();

        for(Room_Item__c r : [SELECT Id, Room__c, Quantity__c, Product2Id__c, Relationship_Type__c, Opportunity_Product__c, Quote_Line_Item__c, Opportunity_Product__r.ListPrice, Opportunity_Product__r.UnitPrice, Quote_Line_Item__r.ListPrice, Quote_Line_Item__r.UnitPrice FROM Room_Item__c WHERE Parent_ID__c =: parentId ]) {

            if(roomItemMap.containsKey(r.Relationship_Type__c)) {

                roomItemMap.get(r.Relationship_Type__c).put(r.Product2Id__c, r);
            }
            else {

                Map <String, Room_Item__c> innerMap = new Map <String, Room_Item__c> ();
                innerMap.put(r.Product2Id__c, r);
                roomItemMap.put(r.Relationship_Type__c, innerMap);
            }
        }

        Set <String> childProductIds = new Set <String> ();
        List <Product_Relationship__c> relationships = new List <Product_Relationship__c> ();

        for(Product_Relationship__c pr : [SELECT Id, Relationship_Type__c, Child_Product__c 
                                          FROM Product_Relationship__c 
                                          WHERE Parent_Product__c =: productId AND Child_Product__r.CurrencyIsoCode =: currencyIsoCode AND Active_Relationship__c = true]) {

            childProductIds.add(pr.Child_Product__c);
            relationships.add(pr);
        }

        if(!childProductIds.isEmpty()) {

            Map <String, PricebookEntry> pricebookEntryMap = new Map <String, PricebookEntry> ();

            for(PricebookEntry p : [SELECT CurrencyIsoCode, Id, IsActive, Name, Product2Id, Product2.Name, ProductCode,  UnitPrice, Product2.Description, Product2.images__c FROM PricebookEntry WHERE Pricebook2.Name = :STANDARD_PRICEBOOK_NAME AND Product2Id =: childProductIds AND CurrencyIsoCode =: currencyIsoCode]) {

                pricebookEntryMap.put(p.Product2Id, p);
            }

            for(Product_Relationship__c pr : relationships) {

                if(pricebookEntryMap.containsKey(pr.Child_Product__c)) {

                    PricebookEntry pe = pricebookEntryMap.get(pr.Child_Product__c);

                    CustomPayload payload = new CustomPayload();
                    payload.UniqueId = '';
                    payload.OpportunityId = '';
                    payload.OpportunitylineItemId = '';
                    payload.PricebookEntryId = pe.Id;
                    payload.Product2Id = pe.Product2Id;
                    payload.Quantity = 0;
                    payload.Description = pe.Product2.Description;
                    payload.ProductCode = pe.ProductCode;
                    payload.ProductName = pe.Product2.Name;
                    payload.Name = pe.Name;
                    payload.UnitPrice = pe.UnitPrice;
                    payload.ListPrice = pe.UnitPrice;
                    payload.CurrencyIsoCode = pe.CurrencyIsoCode;
                    payload.QuoteId = '';
                    payload.QuoteLineItemId = '';
                    payload.ImageUrl = pe.Product2.images__c;
                    payload.ToDelete = false;

                    //relationship 
                    payload.RelationshipType = pr.Relationship_Type__c;
                    payload.RelationshipId = pr.Id;

                    if(roomItemMap.containsKey(payload.RelationshipType)) {
           
                        if(roomItemMap.get(payload.RelationshipType).containsKey(payload.Product2Id)) {
            
                            payload.Checked = true;

                            Room_Item__c tempRi = roomItemMap.get(payload.RelationshipType).get(payload.Product2Id);

                            payload.RoomId = tempRi.Room__c;
                            payload.RoomItemId = tempRi.Id;
                            payload.Quantity = Integer.valueOf(tempRi.Quantity__c);
                            payload.OpportunitylineItemId = tempRi.Opportunity_Product__c;
                            payload.QuoteLineItemId = tempRi.Quote_Line_Item__c;

                            if(tempRi.Quote_Line_Item__r.UnitPrice != null) {

                                payload.UnitPrice = tempRi.Quote_Line_Item__r.UnitPrice;
                            }
                            else {

                                if(tempRi.Opportunity_Product__r.UnitPrice != null) { 

                                    payload.UnitPrice = tempRi.Opportunity_Product__r.UnitPrice;
                                }
                                else {

                                    payload.UnitPrice = payload.UnitPrice;
                                }
                            }

                            if(tempRi.Quote_Line_Item__r.ListPrice != null) {

                                payload.ListPrice = tempRi.Quote_Line_Item__r.ListPrice;
                            }
                            else {

                                if(tempRi.Opportunity_Product__r.ListPrice != null) { 

                                    payload.ListPrice = tempRi.Opportunity_Product__r.ListPrice;
                                }
                                else {

                                    payload.ListPrice = payload.ListPrice;
                                }
                            }
                        }
                    }

                    response.add(payload);
                }
            }
        }

        return response;
    }

    @AuraEnabled
    public static List <CustomPayload> replaceProducts(CustomPayload current, CustomPayload replacement, CustomPayload room) {
        List <CustomPayload> response = new List <CustomPayload> ();

        //delete current product
        deleteProducts(new List<CustomPayload> {current}, room);
        
        //save the new product
        response = saveAllProducts(new List <CustomPayload> {replacement}, room);

        return response;
    }

    public static String generateUniqueId() {
        
        String date1 = String.valueOf(Date.today());
        date1 = date1.replace('-', '');
        Decimal uniqueId = Math.floor(Math.random() * 100000);
		Decimal uniqueId2 = Math.floor(Math.random() * 100000);
		String uniqueIdStr = date1 + String.valueOf(uniqueId) + String.valueOf(uniqueId2);

        return uniqueIdStr;
    }*/

    public class CustomPayload {

        @AuraEnabled public String UniqueId {get;set;}
        @AuraEnabled public String OpportunityId {get;set;}
        @AuraEnabled public String OpportunityLineItemId {get;set;}
        @AuraEnabled public String PricebookEntryId {get;set;}
        @AuraEnabled public String Product2Id {get;set;}
        @AuraEnabled public Decimal CurrentCost {get;set;}
        @AuraEnabled public Integer Quantity {get;set;}
        @AuraEnabled public Integer PreviousQuantity {get;set;}
        @AuraEnabled public Decimal SalesPriceDiscount {get;set;}
        @AuraEnabled public Decimal UnitPrice {get;set;}
        @AuraEnabled public Decimal Margin {get;set;}
        @AuraEnabled public Decimal ListPrice {get;set;}
        @AuraEnabled public Decimal TotalPrice {get;set;}
        @AuraEnabled public String Classification {get;set;}
        @AuraEnabled public String ApprovalNumber {get;set;}
        @AuraEnabled public String Description {get;set;}
        @AuraEnabled public String ProductCode {get;set;}
        @AuraEnabled public String ProductName {get;set;}
        @AuraEnabled public String Name {get;set;}
        @AuraEnabled public String CurrencyIsoCode {get;set;}
        @AuraEnabled public String RoomId {get;set;}
        @AuraEnabled public String RoomItemId {get;set;}
        @AuraEnabled public String QuoteId {get;set;}
        @AuraEnabled public String QuoteLineItemId {get;set;}
        @AuraEnabled public String ImageUrl {get;set;}
        @AuraEnabled public String RelationshipType {get;set;}
        @AuraEnabled public String RelationshipId {get;set;}
        @AuraEnabled public Boolean Checked {get;set;}
        @AuraEnabled public String ParentId {get;set;}
        @AuraEnabled public Boolean DisableViewImage {get;set;}
        @AuraEnabled public Boolean ToDelete {get;set;}
        @AuraEnabled public Decimal Sequence {get;set;}
        
        @AuraEnabled public Integer requiredCount {get;set;}
        @AuraEnabled public Integer recommendedCount {get;set;}
        @AuraEnabled public Integer upsellCount {get;set;}

        @AuraEnabled public String MaterialGroup {get;set;}
        @AuraEnabled public String MaterialNumber {get;set;}
        @AuraEnabled public String ProductHierarchy {get;set;}
        
        @AuraEnabled public List <CustomPayload> children {get;set;}
        
        @AuraEnabled public boolean PriceLocked {get;set;}
        
        public CustomPayload() {

            Checked = false;
            DisableViewImage = false;
            ToDelete = false;
        }
    }
    
    /*private static String getCustomerId(List<CustomPayload> payloads){
        if(String.isNotBlank(payloads[0].OpportunityId)){
            Opportunity opp = [SELECT Id, Account.Sage_External_ID__c FROM Opportunity WHERE id = :payloads[0].OpportunityId];
            
            return opp.Account.Sage_External_ID__c;
        }else if(String.isNotBlank(payloads[0].QuoteId)){
            Quote quote = [SELECT Id, Account.Sage_External_ID__c FROM Quote WHERE id = :payloads[0].QuoteId];
            
            return quote.Account.Sage_External_ID__c;
        }
        
        return null;
    }
    
    @AuraEnabled
    public static List<IntegrationApi.ProductPrice> checkPricing(List<CustomPayload> payloads){
        if(payloads == null || payloads.isEmpty()){
        	return new List<IntegrationApi.ProductPrice>();    
        }
        
        String customerId = getCustomerId(payloads);
        Map<String, List<String>> productIdToCustomerIdListMap = new Map<String, List<String>>();
        for(CustomPayload payload : payloads){
            if(!productIdToCustomerIdListMap.containsKey(payload.Product2Id)){
                productIdToCustomerIdListMap.put(payload.Product2Id, new List<String>{});
            }
            
            productIdToCustomerIdListMap.get(payload.Product2Id).add(customerId);
        }

        Map<String, IntegrationApi.ProductPrice> productIdToProductPriceMap = IntegrationApi.checkPrice(productIdToCustomerIdListMap);
        
        return productIdToProductPriceMap.values();
    }
    
    @AuraEnabled
    public static List<IntegrationApi.StockAvailability> checkAvailability(List<CustomPayload> payloads){
        if(payloads == null || payloads.isEmpty()){
        	return new List<IntegrationApi.StockAvailability>();    
        }
        
        List<Id> productIds = new List<Id>();
        for(CustomPayload payload : payloads){
            productIds.add(payload.Product2Id);
        }
        
        List<IntegrationApi.StockAvailability> stockAvailabilityData = IntegrationApi.checkProductAvailabilityByProductIds(productIds);
        
        // Requirement: Sal_F_Q15
        // IE Internal users should be able to see all stock for UK and IE. 
		// UK Internal users should be able to only see stock in UK.
        boolean isIEAccount = isIEAccount(payloads);
        
        if(!isIEAccount){
            for(IntegrationApi.StockAvailability stockAvailability : stockAvailabilityData){
                stockAvailability.otherWarehousesStock = new List<IntegrationApi.OtherWarehousesStock>();
            }
        }
        
        return stockAvailabilityData;
    }
    
    private static boolean isIEAccount(List<CustomPayload> payloads){
        if(payloads == null || payloads.isEmpty()){
            return false;
        }
        
        // We assume alll payload belonging to same country
        CustomPayload firstPayload = payloads[0];
        
        if(firstPayload.opportunityId != null){
            String shippingCountry = ([SELECT id, Account.ShippingCountry FROM Opportunity WHERE Id = :firstPayload.opportunityId])?.Account?.ShippingCountry;
            
            return shippingCountry == COUNTRY_IRELAND;
        }else if(firstPayload.quoteId != null){
            String shippingCountry = ([SELECT id, Account.ShippingCountry FROM Quote WHERE Id = :firstPayload.quoteId])?.Account?.ShippingCountry;
            
            return shippingCountry == COUNTRY_IRELAND;
        }
        
        return false;
    }
    
    private static boolean isType(String recordId, Schema.DescribeSObjectResult describeResult){
        if(recordId == null){
            return false;
        }
        
        return recordId.startsWith(describeResult.getKeyPrefix());
    }
    
    @AuraEnabled
    public static List<SalesPriceMismatch> detectSalesPriceMismatch(List<CustomPayload> payloads, String recordId){
        List<SalesPriceMismatch> result = new List<SalesPriceMismatch>();
        Map<Id, OpportunityLineItem> productIdToOppLineItemMap = new Map<Id, OpportunityLineItem>();
        Map<Id, QuoteLineItem> productIdToQuoteLineItemMap = new Map<Id, QuoteLineItem>();
        Map<Id, Integer> productIdRoomItemCountMap = new Map<Id, Integer>();
        boolean isOpportunity = isType(recordId, Schema.SObjectType.Opportunity);
        boolean isQuote = isType(recordId, Schema.SObjectType.Quote);
        
        if(isOpportunity){
            Opportunity opportunity = [SELECT Id, (SELECT Id, UnitPrice, Product2Id, Product2.ProductCode, CurrencyIsoCode FROM OpportunityLineItems) FROM Opportunity WHERE Id = :recordId];
            for(OpportunityLineItem oppLineItem : opportunity.OpportunityLineItems){
                productIdToOppLineItemMap.put(oppLineItem.Product2Id, oppLineItem);
            }
            
            /*for(AggregateResult aggregateResult : [SELECT Opportunity_Product__r.Product2Id productId, COUNT(Id) recordCount FROM Room_Item__c WHERE Opportunity_Id__c = :recordId GROUP BY Opportunity_Product__r.Product2Id]){
                productIdRoomItemCountMap.put((Id)aggregateResult.get('productId'), (Integer)aggregateResult.get('recordCount'));
            }*/
            
            /*for(Room_Item__c roomItem : [SELECT Opportunity_Product__r.Product2Id FROM Room_Item__c WHERE Opportunity_Id__c = :recordId]){
                Id productId = roomItem.Opportunity_Product__r.Product2Id;
                
                if(!productIdRoomItemCountMap.containsKey(productId)){
                    productIdRoomItemCountMap.put(productId, 0);
                }
                
                productIdRoomItemCountMap.put(productId, productIdRoomItemCountMap.get(productId) + 1);
            }
        }else if(isQuote){
            Quote quote = [SELECT Id, (SELECT Id, UnitPrice, Product2.ProductCode, CurrencyIsoCode FROM QuoteLineItems) FROM Quote WHERE Id = :recordId];
            for(QuoteLineItem quoteLineItem : quote.QuoteLineItems){
                productIdToQuoteLineItemMap.put(quoteLineItem.Product2Id, quoteLineItem);
            }
            
            for(AggregateResult aggregateResult : [SELECT Quote_Line_Item__r.Product2Id productId, COUNT(Id) recordCount FROM Room_Item__c WHERE Quote_Id__c = :recordId GROUP BY Quote_Line_Item__r.Product2Id]){
                productIdRoomItemCountMap.put((Id)aggregateResult.get('productId'), (Integer)aggregateResult.get('recordCount'));
            }
        }
        
        System.debug('productIdToOppLineItemMap: ' + productIdToOppLineItemMap);
        System.debug('productIdToQuoteLineItemMap: ' + productIdToQuoteLineItemMap);
        System.debug('productIdRoomItemCountMap: ' + productIdRoomItemCountMap);
        System.debug('payloads: ' + payloads);
        
        for(CustomPayload payload : payloads){
            System.debug('payload: ' + payload);
            
            if(payload.ToDelete){
                continue;
            }   
            
            String productId = payload.Product2Id;
            boolean isNew = payload.roomItemId == null;
            boolean isMismatch = false;
            
            
            System.debug('isNew: ' + isNew);
            
            if(isOpportunity){
                OpportunityLineItem oppLineItem = productIdToOppLineItemMap.get(productId);
                
                if(isNew){
                    if(oppLineItem != null && isDifferent(payload.UnitPrice, oppLineItem.UnitPrice)){
                        isMismatch = true;
                    }
                }else{
                	integer roomItemCount = productIdRoomItemCountMap.get(productId);
                    
                    if(oppLineItem != null && isDifferent(payload.UnitPrice, oppLineItem.UnitPrice) && roomItemCount > 1){
                        isMismatch = true;
                    }
                }
                
                if(isMismatch){
                    result.add(createSalesPriceMismatch(
                        	productId,
                            oppLineItem.Product2.ProductCode,
                            oppLineItem.CurrencyIsoCode,
                            new List<Decimal>{
                                payload.UnitPrice, 
                                oppLineItem.UnitPrice
                            }
                    ));
                }
            }else if(isQuote){
                QuoteLineItem quoteLineItem = productIdToQuoteLineItemMap.get(productId);
                
                if(isNew){
                    if(quoteLineItem != null && isDifferent(payload.UnitPrice, quoteLineItem.UnitPrice)){
                        isMismatch = true;
                    }
                }else{
                    integer roomItemCount = productIdRoomItemCountMap.get(productId);
                    
                    if(quoteLineItem != null && isDifferent(payload.UnitPrice, quoteLineItem.UnitPrice) && roomItemCount > 1){
                        isMismatch = true;
                    }
                }
                
                if(isMismatch){
                    result.add(createSalesPriceMismatch(
                        	productId,
                            quoteLineItem.Product2.ProductCode,
                            quoteLineItem.CurrencyIsoCode,
                            new List<Decimal>{
                                payload.UnitPrice, 
                                quoteLineItem.UnitPrice
                            }
                    ));
                }
            }
        }
        
        System.debug('result: ' + result);
        
        return result;
    }
    
    @AuraEnabled(cacheable=true)
    public static boolean canViewMargin(String roomId){
        Room__c room = [SELECT Id, Opportunity__c, Quote__c FROM Room__c WHERE Id = :roomId];
        
        if(room.Opportunity__c != null){
            return OpportunityLineItem.Margin__c.getDescribe().isAccessible();
        }else if(room.Quote__c != null){
            return QuoteLineItem.Margin__c.getDescribe().isAccessible();
        }
        
        return false;
    }
    
    private static boolean isDifferent(Decimal val1, Decimal val2){
        return Math.abs(val1 - val2) > 0.001;
    }
    
    private static SalesPriceMismatch createSalesPriceMismatch(String productId, String productCode, String currencyCode, List<Decimal> values){
		SalesPriceMismatch result = new SalesPriceMismatch();
		result.productId = productId;
		result.productCode = productCode;
		result.salesPrices = new List<SalesPrice>();

        for(Decimal value : values){
            SalesPrice salesPrice = new SalesPrice();
            salesPrice.currencyCode = currencyCode;
            salesPrice.value = value;
            
            result.salesPrices.add(salesPrice);
        }        
        
        return result;
    }
    
    @AuraEnabled(cacheable=true)
    public static boolean isReadOnly(String recordId){
        boolean isOpportunity = isType(recordId, Schema.SObjectType.Opportunity);
        
        if(!isOpportunity){
            return false;
        }
        
        Opportunity opportunity = [SELECT Id, (SELECT Id, Is_Syncing_Custom__c FROM Quotes) FROM Opportunity WHERE Id = :recordId];
        
        for(Quote quote : opportunity.Quotes){
            if(quote.Is_Syncing_Custom__c == true){
                return true;
            }
        }
        
        return false;
    } 

    @AuraEnabled(cacheable=true)
    public static List<Product2> getProductData(){
        String query = 'select name, category__c, brand__c, range__c, colour__c, productheightmm__c, productwidthmm__c, tapholes__c, flowrateat02bar__c, flowrateat05bar__c, flowrateat1bar__c, flowrateat2bar__c, flowrateat3bar__c, flowrateat4bar__c, flowrateat5bar__c from product2 Where isactive=true ';
        
        return Database.query(query);
    }
    
    public class SalesPrice{
        @AuraEnabled
        public String currencyCode {get;set;}
        
        @AuraEnabled
        public Decimal value {get;set;}
    }
    
    public class SalesPriceMismatch{
        @AuraEnabled
        public String productId {get;set;}
        
        @AuraEnabled
        public String productCode {get;set;}
        
        @AuraEnabled
        public List<SalesPrice> salesPrices {get;set;}
    }

    public class CustomPayload_Room {

        @AuraEnabled public String roomName {get;set;}
        @AuraEnabled public Decimal sequence {get;set;}
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String opportunityId {get;set;}
        @AuraEnabled public String quoteId {get;set;}
    }*/
}