import urllib.request, urllib.error, urllib.parse
import json

REST_URL = "http://data.bioontology.org"
API_KEY = "<secret>"

sourceOntoAbbr = "RXNORM"
constrainDestOnto = False
destOntoUriList   = []

PAGE_SIZE = 500
	
def get_json(url):
    opener = urllib.request.build_opener()
    opener.addheaders = [('Authorization', 'apikey token=' + API_KEY)]
    return json.loads(opener.open(url).read())
page = get_json(REST_URL+"/ontologies/" + sourceOntoAbbr + "/mappings?pagesize=" + str(PAGE_SIZE ))
	
pagecount = page["pageCount"]
next_page = page
while next_page:
    for ndfrt_mapping in page["collection"]:
        mapsource = ndfrt_mapping["source"]
        internal = ndfrt_mapping["classes"][0]["@id"]
        external = ndfrt_mapping["classes"][1]["@id"]
        extont = ndfrt_mapping["classes"][1]["links"]["ontology"]
        if ((extont in destOntoUriList) or (not constrainDestOnto)):
            combo = internal + "\t" + mapsource + "\t" +  extont + "\t" + external
            print(combo)
    next_page = page["links"]["nextPage"]
    if next_page:
        page = get_json(next_page)
		