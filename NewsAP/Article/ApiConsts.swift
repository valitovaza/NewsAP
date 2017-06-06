let ApiKey = "YOUR_KEY"
enum ResponseStatus: String {
    case ok
    case error
}
enum SortType: String {
    case top
    case latest
    case popular
}
enum SourceCategory: String {
    case business
    case entertainment
    case gaming
    case general
    case music
    case politics
    case scienceAndNature = "science-and-nature"
    case sport
    case technology
}
enum Language: String {
    case en
    case de
    case fr
}
enum Country: String {
    case au
    case de
    case gb
    case In = "in"
    case it
    case us
}
