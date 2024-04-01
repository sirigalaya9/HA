/**
 * Reduces one or more LDS errors into a string[] of error messages.
 * @param {FetchResponse|FetchResponse[]} errors
 * @return {String[]} Error messages
 */
export function reduceErrors(errors) {
    if (!Array.isArray(errors)) {
        errors = [errors];
    }
    
    return (
        errors
            // Remove null/undefined items
            .filter((error) => !!error)
            // Extract an error message
            .map((error) => {                
                // UI API read errors
                if (Array.isArray(error.body)) {
                    console.log('UI API Read error');
                    return error.body.map((e) => e.message);
                }
                else if (error.body && error.body.fieldErrors && error.body.fieldErrors.length > 0 && Array.isArray(error.body.fieldErrors)) {
                    console.log('Field Error 1');
                    return error.body.fieldErrors.map((e) => e.message);
                }                                
                else if (error.body && error.body.fieldErrors && Object.keys(error.body.fieldErrors).length > 0) {
                    console.log('Field Error 2');
                    return Object.keys(error.body.fieldErrors).map((e) => error.body.fieldErrors[e][0].message);
                }
                //Record error                
                else if (error.body && error.body.output && error.body.output.fieldErrors && Object.keys(error.body.output.fieldErrors).length > 0) {
                    console.log('Field Error 3');
                    return Object.keys(error.body.output.fieldErrors).map((e) => error.body.output.fieldErrors[e][0].message);
                }  
                //Validation error                
                else if ((error.body && error.body.output && error.body.output.errors && Object.keys(error.body.output.errors).length > 0)) {
                    let msg = error.body.output.errors[0].message;
                    console.error('Validation error', msg);                    
                    let broilerIndex = msg.indexOf('. You can look up ExceptionCode values in the SOAP API Developer Guide.');                    
                    if (broilerIndex > -1)
                    {
                        msg = msg.slice(0, broilerIndex);
                        let customValidationIndex = msg.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION: ');
                        if (customValidationIndex > -1)
                        {
                            msg = msg.slice(customValidationIndex);
                            msg = msg.replace('FIELD_CUSTOM_VALIDATION_EXCEPTION: ','');
                        }
                    }
                    return msg;
                }                                                             
                else if (error.body && error.body.pageErrors && error.body.pageErrors.length > 0 && Array.isArray(error.body.pageErrors)) {
                    console.log('Page Error');
                    return error.body.pageErrors.map((e) => e.message);
                }
                else if (Array.isArray(error.body)) {
                    return error.body.map((e) => e.message);
                }                
                // UI API DML, Apex and network errors
                else if (error.body && typeof error.body.message === 'string') {
                    let msg = error.body.message;
                    console.error('Validation error', msg);                    
                    let customValidationIndex = msg.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION, ');
                    if (customValidationIndex > -1)
                    {
                        msg = msg.slice(customValidationIndex);
                        msg = msg.replace('FIELD_CUSTOM_VALIDATION_EXCEPTION, ','');
                        msg = msg.replace(',',' ');
                        console.error(msg);
                    }                  
                    return msg;
                }
                // JS errors
                else if (typeof error.message === 'string') {
                    return error.message;
                }
                // Unknown error shape so try HTTP status text
                return error.statusText;
            })
            // Flatten
            .reduce((prev, curr) => prev.concat(curr), [])
            // Remove empty strings
            .filter((message) => !!message)
    ).toString();
}
/**
 * Generates Globally Unique ID.
 * @param 
 * @return {String} GUID
 */
export function generateGUID() {
    return ([1e7] + -1e3 + -4e3 + -8e3 + -1e11).replace(/[018]/g, c =>
        (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16)
    );
}