using System.Net;
using Newtonsoft.Json;

public static async Task<HttpResponseMessage> Run(HttpRequestMessage req, TraceWriter log)
{
    log.Info("C# HTTP trigger function to process fluentd output request.");
    log.Info( string.Format("Dump request:\n {0}",req.ToString()));

    // parse query parameter
    string payload = req.GetQueryNameValuePairs()
        .FirstOrDefault(q => string.Compare(q.Key, "payload", true) == 0)
        .Value;

    // Get request body
    dynamic data = await req.Content.ReadAsAsync<object>();

    if (data.payload == null) {
        log.Info("Please pass a payload on the query string or in the request body");
        return new HttpResponseMessage(HttpStatusCode.BadRequest);
    }
    // Process Your Jobs!
    dynamic r = JsonConvert.DeserializeObject<dynamic>((string)data.payload);
    if (r.key1!=null) log.Info(string.Format("key1={0}",r.key1));
    if (r.key2!=null) log.Info(string.Format("key2={0}",r.key2));
    if (r.key3!=null) log.Info(string.Format("key3={0}",r.key3));
    if (r.mytime!=null) log.Info(string.Format("mytime={0}",r.mytime));
    if (r.mytag!=null) log.Info(string.Format("mytag={0}",r.mytag));
 
    return new HttpResponseMessage(HttpStatusCode.OK);
}
