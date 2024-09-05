import Foundation

// swiftlint:disable identifier_name
///  A locale code to use for a transaction.
@objc public enum BTPayPalLocaleCode: Int {
    case none
    case da_DK
    case de_DE
    case en_AU
    case en_GB
    case en_US
    case es_ES
    case es_XC
    case fr_CA
    case fr_FR
    case fr_XC
    case id_ID
    case it_IT
    case ja_JP
    case ko_KR
    case nl_NL
    case no_NO
    case pl_PL
    case pt_BR
    case pt_PT
    case ru_RU
    case sv_SE
    case th_TH
    case tr_TR
    case zh_CN
    case zh_HK
    case zh_TW
    case zh_XC
    // swiftlint:enable identifier_name

    var stringValue: String? {
        switch self {
        case .none:
            return nil
        case .da_DK:
            return "da_DK"
        case .de_DE:
            return "de_DE"
        case .en_AU:
            return "en_AU"
        case .en_GB:
            return "en_GB"
        case .en_US:
            return "en_US"
        case .es_ES:
            return "es_ES"
        case .es_XC:
            return "es_XC"
        case .fr_CA:
            return "fr_CA"
        case .fr_FR:
            return "fr_FR"
        case .fr_XC:
            return "fr_XC"
        case .id_ID:
            return "id_ID"
        case .it_IT:
            return "it_IT"
        case .ja_JP:
            return "ja_JP"
        case .ko_KR:
            return "ko_KR"
        case .nl_NL:
            return "nl_NL"
        case .no_NO:
            return "no_NO"
        case .pl_PL:
            return "pl_PL"
        case .pt_BR:
            return "pt_BR"
        case .pt_PT:
            return "pt_PT"
        case .ru_RU:
            return "ru_RU"
        case .sv_SE:
            return "sv_SE"
        case .th_TH:
            return "th_TH"
        case .tr_TR:
            return "tr_TR"
        case .zh_CN:
            return "zh_CN"
        case .zh_HK:
            return "zh_HK"
        case .zh_TW:
            return "zh_TW"
        case .zh_XC:
            return "zh_XC"
        }
    }
}
