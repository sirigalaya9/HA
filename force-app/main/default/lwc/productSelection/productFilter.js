const RANGE_FIELDS = ["productheightmm__c", "productwidthmm__c"];
const SELECT_ALL_VALUE = "-";
const SELECT_ALL_LABEL = "-";

class ProductFilter{
    _productData = [];
    _selectedFilters = [];

    set productData(value){
        this._productData = value;
    }

    get productData(){
        return this._productData;
    }

    selectFilter(name, value){
        let isAlreadySelected = this._selectedFilters.some(filter => filter.name === name);
        if(isAlreadySelected){
            let index = this._selectedFilters.findIndex(filter => filter.name === name);

            if(value === SELECT_ALL_VALUE){
                this._selectedFilters.splice(index);
                return;
            }
            
            // Override the value of the selected filter
            this._selectedFilters[index] = {name, value};

            // Remove all filters after the selected filter
            this._selectedFilters.splice(index + 1);
        }else if(value !== SELECT_ALL_VALUE){
            this._selectedFilters.push({name, value});
        }
    }

    createOptions(data, name){
        if(name === "flowrate"){
            return this.createFlowrateOptions(data);
        } else if(RANGE_FIELDS.includes(name)){
            return this.createOptionsRangeField(data, name);
        }
            
        return this.createOptionsDefault(data, name);
    }

    createFlowrateOptions(data){
        let flowrate02BarAvailable = data.some(element => element.flowrateat02bar__c !== undefined);
        let flowrate05BarAvailable = data.some(element => element.flowrateat05bar__c !== undefined);
        let flowrate1BarAvailable = data.some(element => element.flowrateat1bar__c !== undefined);
        let flowrate2BarAvailable = data.some(element => element.flowrateat2bar__c !== undefined);
        let flowrate3BarAvailable = data.some(element => element.flowrateat3bar__c !== undefined);
        let flowrate4BarAvailable = data.some(element => element.flowrateat4bar__c !== undefined);
        let flowrate5BarAvailable = data.some(element => element.flowrateat5bar__c !== undefined);

        let result = [];

        if(flowrate02BarAvailable){
            result.push({
                label: "0.2 Bar",
                value: "flowrateat02bar__c"
            });
        }

        if(flowrate05BarAvailable){
            result.push({
                label: "0.5 Bar",
                value: "flowrateat05bar__c"
            });
        }

        if(flowrate1BarAvailable){
            result.push({
                label: "1 Bar",
                value: "flowrateat1bar__c"
            });
        }

        if(flowrate2BarAvailable){
            result.push({
                label: "2 Bar",
                value: "flowrateat2bar__c"
            });
        }

        if(flowrate3BarAvailable){
            result.push({
                label: "3 Bar",
                value: "flowrateat3bar__c"
            });
        }

        if(flowrate4BarAvailable){
            result.push({
                label: "4 Bar",
                value: "flowrateat4bar__c"
            });
        }

        if(flowrate5BarAvailable){
            result.push({
                label: "5 Bar",
                value: "flowrateat5bar__c"
            });
        }

        // Add the default option
        result.unshift({
            label: SELECT_ALL_LABEL,
            value: SELECT_ALL_VALUE
        });

        return result;
    }

    createOptionsRangeField(data, name, step = 100){
        let values = [];
        let hasEmptyValue = false;

        data.forEach(element => {
            let value = element[name];

            if(value === undefined){
                hasEmptyValue = true;
                return;
            }

            if(!values.includes(value)){
                values.push(Number(value));
            }
        });

        let result = [];

        // Sort the array
        values.sort((a, b) => a - b);

        let alreadyAdded = new Set();
        for(let value of values){
            let lowerBound = Math.floor(value / step) * step;
            let upperBound = Math.ceil(value / step) * step;
            let option = `${lowerBound} - ${upperBound}`;

            if(lowerBound === upperBound){
                option = `${upperBound} - ${upperBound + step}`
            }

            if(alreadyAdded.has(option)){
                continue;
            }

            result.push({
                label: option,
                value: option
            });

            alreadyAdded.add(option);
        }

        if(hasEmptyValue){
            result.push({
                label: "(Blanks)",
                value: ""
            });
        }

        // Add the default option
        result.unshift({
            label: SELECT_ALL_LABEL,
            value: SELECT_ALL_VALUE
        });

        return result;
    }

    createOptionsDefault(data, name){
        let result = [];
        let hasEmptyValue = false;
        let isNumberField = name.startsWith("flowrate");
        
        data.forEach(element => {
            let value = element[name];

            if(value === undefined){
                hasEmptyValue = true;
                return;
            }

            if(!result.includes(value)){
                if(isNumberField){
                    value = Number(value);
                }

                result.push(value);
            }
        });

        // Sort the array
        if(isNumberField){
            result.sort((a, b) => a - b);
        }else{
            result.sort();
        }

        result = result.map(element => {
            return {
                label: element,
                value: "" + element // always convert to string
            }
        });

        if(hasEmptyValue){
            result.push({
                label: "(Blanks)",
                value: ""
            });
        }

        // Add the default option
        result.unshift({
            label: SELECT_ALL_LABEL,
            value: SELECT_ALL_VALUE
        });

        return result;
    }

    updateFilterOptions(filterOptions){
        let filterNames = ["category__c", "brand__c", "range__c", "colour__c", "tapholes__c", "productheightmm__c", "productwidthmm__c", "flowrate",
        "flowrateat02bar__c", "flowrateat05bar__c", "flowrateat1bar__c", "flowrateat2bar__c", "flowrateat3bar__c", "flowrateat4bar__c", "flowrateat5bar__c"];
        let filterData = [...this.productData];

        for(let selectedFilter of this._selectedFilters){
            if(filterNames.includes(selectedFilter.name)){
                if(selectedFilter.name === "flowrate"){
                    filterOptions.flowrate = this.createOptions(filterData, "flowrate");
                    filterData = filterData.filter(item => {
                        return item[selectedFilter.value] != null;
                    });
                    continue;
                }

                filterOptions[selectedFilter.name] = this.createOptions(filterData, selectedFilter.name);

                filterData = filterData.filter(element => {
                    if(RANGE_FIELDS.includes(selectedFilter.name)){
                        let selectedFilterValue = selectedFilter.value;
                        if(selectedFilterValue !== ""){
                            let lowerBound = selectedFilterValue.split("-")[0].trim();
                            let upperBound = selectedFilterValue.split("-")[1].trim();

                            return element[selectedFilter.name] >= lowerBound && element[selectedFilter.name] < upperBound;
                        }
                            
                        return element[selectedFilter.name] === undefined || element[selectedFilter.name] === "";
                    }

                    return element[selectedFilter.name] == selectedFilter.value;
                });
            }
        }

        for(let filterName of filterNames){
            if(!filterOptions[filterName]){
                filterOptions[filterName] = this.createOptions(filterData, filterName);
            }
        }
    }

    isFilterSelected(filterName){
        return this._selectedFilters.find(element => {
            return element.name === filterName;
        }) !== undefined;
    }

    hasOptionsToChoose(options){
        let optionsWithoutSelectAll = options.filter(option => option.value !== SELECT_ALL_VALUE);

        if(optionsWithoutSelectAll.length === 0){
            return false;
        }

        let onlyHasBlanksOption = optionsWithoutSelectAll.length === 1 && optionsWithoutSelectAll[0].value === "";
        if(onlyHasBlanksOption){
            return false;
        }

        return true;
    }

    get data(){
        let filterOptions = {};

        this.updateFilterOptions(filterOptions);

        let selectedFilterValues =  this._selectedFilters.reduce((map, obj) => {
            map[obj.name] = obj.value;
            return map;
        }, {});

        let visibility = {
            showRange: this.hasOptionsToChoose(filterOptions.range__c),
            showColour: this.hasOptionsToChoose(filterOptions.colour__c),
            showTapholes: this.hasOptionsToChoose(filterOptions.tapholes__c),
            showProductHeight: this.hasOptionsToChoose(filterOptions.productheightmm__c),
            showProductWidth: this.hasOptionsToChoose(filterOptions.productwidthmm__c),
            showFlowrate: this.hasOptionsToChoose(filterOptions.flowrate),
            showFlowrate02Bar: this.isFilterSelected("flowrate") && selectedFilterValues.flowrate === "flowrateat02bar__c",
            showFlowrate05Bar: this.isFilterSelected("flowrate") && selectedFilterValues.flowrate === "flowrateat05bar__c",
            showFlowrate1Bar: this.isFilterSelected("flowrate") && selectedFilterValues.flowrate === "flowrateat1bar__c",
            showFlowrate2Bar: this.isFilterSelected("flowrate") && selectedFilterValues.flowrate === "flowrateat2bar__c" ,
            showFlowrate3Bar: this.isFilterSelected("flowrate") && selectedFilterValues.flowrate === "flowrateat3bar__c",
            showFlowrate4Bar: this.isFilterSelected("flowrate") && selectedFilterValues.flowrate === "flowrateat4bar__c",
            showFlowrate5Bar: this.isFilterSelected("flowrate") && selectedFilterValues.flowrate === "flowrateat5bar__c"
        };

        return {
            filterOptions,
            selectedFilters: this._selectedFilters,
            // Convert the array of selected filters to a map
            // Example: {category__c: "category1", brand__c: "brand1"}
            selectedFilterValues: selectedFilterValues,
            visibility: visibility
        };
    }

    reset(){
        this._selectedFilters = [];
    }
}

export default ProductFilter;