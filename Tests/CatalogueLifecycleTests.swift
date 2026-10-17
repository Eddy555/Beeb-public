import Foundation
@main struct CatalogueLifecycleTests {
    @MainActor static func main() async throws {
        let folder=FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer {try? FileManager.default.removeItem(at:folder)}
        let cache=DiscoveryCache(folder:folder)
        let minimal=HomeFeed(features:[],rows:[HomeRow(id:"popular",title:"Popular",shows:[])])
        try await cache.write(minimal,key:"homepage")
        let log=RequestLogForLifecycle()
        let fail=DiscoveryAPI(fetch:{url in await log.record(url);throw BBCError.message("Offline")})
        let store=CatalogueStore(discovery:fail,cache:cache)
        await store.boot()
        precondition(store.home?.rows.first?.id=="popular" && store.error != nil,"Offline launch keeps lightweight homepage cache")
        let paths=await log.paths()
        precondition(paths.count==2 && !paths.contains(where:{$0.contains("atoz")||$0.contains("episodes")}),"Launch requests only homepage and categories; no catalogue crawl")
        let raw:[String:Any]=["id":"b0000001","title":"A show","count":1,"tleo_type":"brand"]
        let data=try JSONSerialization.data(withJSONObject:["atoz_programmes":["page":1,"per_page":30,"count":60,"elements":[raw]]])
        let pages=PageStore(api:DiscoveryAPI(fetch:{_ in data}),cache:cache)
        await pages.load(letter:"a",page:1)
        precondition(pages.shows.count==1 && pages.totalPages==2,"Page metadata retained")
        let offline=PageStore(api:fail,cache:cache)
        await offline.load(letter:"a",page:1)
        precondition(offline.shows.count==1 && offline.totalPages==2 && offline.error != nil,"Offline browsing restores cached page and pagination")
        print("PASS: lightweight offline launch, absence of full-catalogue requests, page cache and pagination restoration")
    }
}
actor RequestLogForLifecycle {
    var values=[String]()
    func record(_ url:URL){values.append(url.path)}
    func paths()->[String]{values}
}
