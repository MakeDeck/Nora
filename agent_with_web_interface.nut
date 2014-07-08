// Nora Reference Design Agent Firmware
// http://electricimp.com/docs/hardware/resources/reference-designs/nora/
// Copyright (C) 2013-2014 Electric Imp, Inc.
// This file is licensed under the MIT License
// http://opensource.org/licenses/MIT

battery <- "";
light <- "";
temperature <- "";
celcius <- "";
farenheit <- "";
pressure <- "";
humidity <- "";

const html1 = @"<!DOCTYPE html>
<html lang=""en"">
    <head>
        <meta charset=""utf-8"">
        <meta http-equiv=""refresh"" content=""300"">
        <meta name=""viewport"" content=""width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0"">
        <meta name=""apple-mobile-web-app-capable"" content=""yes"">
        
        <script src=""http://code.jquery.com/jquery-1.9.1.min.js""></script>
        <script src=""http://code.jquery.com/jquery-migrate-1.2.1.min.js""></script>
        <script src=""http://d2c5utp5fpfikz.cloudfront.net/2_3_1/js/bootstrap.min.js""></script>
        
        <link href=""//d2c5utp5fpfikz.cloudfront.net/2_3_1/css/bootstrap.min.css"" rel=""stylesheet"">
        <link href=""//d2c5utp5fpfikz.cloudfront.net/2_3_1/css/bootstrap-responsive.min.css"" rel=""stylesheet"">
        <link rel=""shortcut icon"" href=""//cdn.shopify.com/s/files/1/0370/6457/files/favicon.ico?802"">
        <title>Nora Sensor Node</title>
    </head>
    <body style=""background-color:#666666"">
        <div class='container'>
            <div class='well' style='max-width: 640px; margin: 0 auto 10px; text-align:center;'>
        
            <img src=""//cdn.shopify.com/s/files/1/0370/6457/files/red_black_logo_side_300x100.png?800"">
                
                <h1>Nora<h1>
                <h3>Electric Imp Environmental Sensor Node</h3>
                <h2>Temperature:</h2><h1>";
const html2 = @"&degF</h1>
                <h2>Humidy:</h2><h1>";
const html3 = @"%</h1>
                <h2>Pressure:</h2><h1>";
const html4 = @" kPa</h1>
                <h2>Light:</h2><h1>";
const html5 = @" Lux</h1>
                <h2>Battery Voltage:</h2><h1>";
const html6 = @" V</h1>
            <img src=""//cdn.shopify.com/s/files/1/0370/6457/files/built-for-imp_300px.png?801"">
            </div>
        </div>
    </body>
</html>";

http.onrequest(function(request, response) { 
    if (request.body == "") {
        local html = html1 + farenheit + html2 + humidity + html3 + pressure + html4 + light + html5 + battery + html6;
        response.send(200, html);
    }
    else {
        response.send(500, "Internal Server Error: ");
    }
});
//----------------------------------------------------------------------
function remote(dev, method, params=[], callback=null, clear=true) {
  
    // Convert strings to tables
    if (typeof params == "string") {
        params = [params];
    }
    
    // Set a temporary event handler
    local event = dev + "." + method;
    device.on(event, function(res) {
        // Clear the old event handler and call the callback
        if (clear) device.on(event, function(d){});
        if (callback) callback(res);
    });
    
    // Send the request to the device
    device.send(dev, {method=method, params=params});
}

//----------------------------------------------------------------------
function read_remote_data(dummy = null) {
  
    /*
    // Read the individual sensors
    remote("thermistor", "read", [], function(res) {
        if (res) server.log("Temp: " + res.temperature + ", Humidity: " + res.humidity);
    })
    
    remote("pressure", "read", [], function (res) {
        if (res) server.log("Pressure: " + res.pressure);
    });
    
    remote("light", "read", [], function (res) {
        if (res) server.log("Lux: " + res.lux);
    });
    
    remote("battery", "read", [], function (res) {
        if (res) server.log(format("Battery: %0.02fV, %0.02f%%", res.volts, res.capacity));
    });
    
    // Read the temperature sensor and setup a waking thermostat
    remote("temperature", "read", [], function(res) {
        if (res) {
            server.log("Temperature: " + res.temperature);
            local min = (res.temperature-2.5).tointeger();
            local max = (res.temperature+2.5).tointeger();
            remote("temperature", "thermostat", [min, max], function(res) {
                server.log("Thermostat triggered at: " + (res.temperature));
            }, false);
            remote("temperature", "sleep", [600, 1]);
        }
    })

    // Reads the temperature when not in one-shot mode
    remote("temperature", "read_temp", [0x00], function(res) {
        if (res) {
            server.log("Temperature: " + res.temperature);
        }
    });

    // Read the accelerometer and setup a waking movement detector
    remote("accelerometer", "read", [], function (res) {
        if (res) {
            remote("accelerometer", "movement_detect", [], function (res) {
                remote("accelerometer", "stop", [], function(res) {
                    remote("accelerometer", "read", [], function (res) {
                        server.log("--------------------------");
                        server.log(format("Acceleration: [X: %0.02f, Y: %0.02f, Z: %0.02f]", res.x, res.y, res.z));
                        read_remote_data();
                    });
                });
            }, false);
            remote("accelerometer", "sleep", [600, 5]);
        }
    });

    // Send continuous stream of changes to the position of the Nora. Won't wake up Nora.
    local threshold = 0.3;
    local thresholds = { low = -threshold, high = threshold, axes = "XY"};
    remote("accelerometer", "threshold", [thresholds], function (res) {
        // server.log(format("Acceleration: [X: %0.02f, Y: %0.02f, Z: %0.02f]", res.x, res.y, res.z));
        if (res) {
            local pitch = "";
            if (res.x <= -threshold) pitch = "back";
            else if (res.x >= threshold) pitch = "forward";
            else pitch = "stop";
            
            local roll = "";
            if (res.y <= -threshold) roll = "right";
            else if (res.y >= threshold) roll = "left";
            else roll = "straight";
            
            server.log("Pitch: " + pitch + ", Roll: " + roll);

        }
        read_remote_data();
    })
    */

    // Request nora to read all sensors once a minute, sleeping offline in between, and after 5 readings, come online and present the data
    remote("nora", "read", [60, 5], function (resultset) {
        foreach (resultid,result in resultset) {
            server.log("------------[ Result set " + resultid + " ]------------")
            foreach (sensor in result) {
                foreach (k,v in sensor.value) {
                    server.log(format("... %s[%d].%s: %0.02f", sensor.name, resultid, k, v))
                    if (sensor.name == "battery") { battery = format("%0.02f", v); }
                    else if (sensor.name == "temperature") {
                        temperature = format("%0.02f", v);
                        local cel = temperature.tointeger();
                        local fah = (((cel*9)/5)+32);
                        farenheit = fah.tostring();
                        celcius = cel.tostring();
                    }
                    else if (k == "humidity") { humidity = format("%0.02f", v); }
                    else if (k == "lux") { light = format("%0.02f", v); }
                    else if (k == "pressure") { pressure = format("%0.02f", v); }
                }
            }
        }
        channel1.Set(farenheit, "Temperature"+mac);
        channel2.Set(humidity, "Humidity"+mac);
        feed <- Xively.Feed("622539647", [channel1, channel2]);
        client.Put(feed);
    }, false);
    
}


//----------------------------------------------------------------------
device.on("ready", read_remote_data);
server.log("Agent started")
