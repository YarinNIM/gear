const webpack = require('webpack');
module.exports = {
    output: { 
        filename: '[name].js' 
    },

    optimization: {},

    externals: {
        'react':'React',
        'react-drom': 'ReactDOM',
        'react-router':'ReactRouter',
        'object-assign': 'Object.assign'
    },

    module: {
        rules: [
            {
                test: /\.(js|jsx)$/,
                exclude: /node_modules/,
                use: { loader: "babel-loader" }
            }
        ]
    }
};
