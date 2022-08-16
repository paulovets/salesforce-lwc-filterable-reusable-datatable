const action = {
    type: 'action',
    typeAttributes: { 
        rowActions: [
            { label: 'Show details', name: 'show_details' }
        ] 
    },
    cellAttributes: { alignment: 'right' },
};

function buildColumns(apexFieldsConfigurations) {
    const mapType = (config) => {
        const type = config.type.toLowerCase();
        switch (type) {
            case "string":
                let pathParts = config.fieldName.split(".");
                if (pathParts.length === 1 && pathParts[1] !== "Id") {
                    return { type : "text" };
                }

                return {
                    fieldName: `${pathParts[0]}.Url`,
                    type: 'url',
                    typeAttributes: {
                        label: { fieldName: config.fieldName }, 
                        target: '_blank'
                    }
                };
            case "datetime":
                return { 
                    type : "date",
                    typeAttributes:{
                        year: "numeric",
                        month: "numeric",
                        day: "2-digit",
                        hour: "2-digit",
                        minute: "2-digit",
                        second: "2-digit"
                    }
                };
            case "date":
                return { type : "date-local" };
            default:
                return { type: type };
          }
    };

    return [action].concat(
        apexFieldsConfigurations
            .filter((config) => config.label )
            .map((config) => {
                return { ...config, ...mapType(config) };
            })
    )
}

function buildRecords(apexRecords) {
    const addUrlFieldIfApplicable = (record) => {
        const recordWithUrl = {};
        for (let key in record) {
            if (!record.hasOwnProperty(key)) {
                continue;
            }

            let pathParts = key.split(".");
            let parentRecordIdKey = `${pathParts[0]}.Id`;
            if (!pathParts.length > 1 || 
                recordWithUrl[`${pathParts[0]}.Url`] ||
                !record[parentRecordIdKey]) {
                continue;
            }

            recordWithUrl[`${pathParts[0]}.Url`] = `/${record[parentRecordIdKey]}`;
        }

        return {
            ...record,
            ...recordWithUrl
        };
    }

    const flattenRecord = (value, parentKey) => {
        if (typeof value !== 'object') {
            const result = {};
            result[parentKey] = value;
    
            return result;
        }
    
        let result = {};
    
        for (var key in value) {
            if (!value.hasOwnProperty(key)) continue;
    
            const resultKey = parentKey ? `${parentKey}.${key}` : key;
    
            result = { ...result, ...flattenRecord(value[key], resultKey) };
        }
    
        return result;
    }

    return apexRecords
        // To don't pass an index - map through the additional arrow function.
        .map((record) => {
            return flattenRecord(record);
        })
        .map(addUrlFieldIfApplicable);
}

export { buildColumns, buildRecords }