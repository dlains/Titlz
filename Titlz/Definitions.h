//
//  Definitions.h
//  Titlz
//
//  Created by David Lains on 1/12/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#ifndef Titlz_Definitions_h
#define Titlz_Definitions_h

#define CustomButtonHeight 30.0

typedef enum SelectionModeEnum
{
    DetailSelection = 0,
    SingleSelection,
    MultipleSelection
} SelectionMode;

typedef enum AwardDetailSectionsEnum
{
    AwardDataSection = 0,
    AwardDetailSectionCount,
} AwardDetailSections;

typedef enum AwardDataSectionRowsEnum
{
    AwardNameRow = 0,
    AwardCategoryRow,
    AwardYearRow,
    AwardDataSectionRowCount,
} AwardDataSectionRows;

typedef enum HomeSectionsEnum
{
    HomeRecentAdditionsSection = 0,
    HomeCollectionSizeSection,
    HomeCollectionValueSection,
    HomeCollectionCostSection,
    HomeCollectionTotalSection,
    HomeSectionCount
} HomeSections;

typedef enum PersonTypeEnum
{
    Workers = 0,
    Alias,
    Signature,
} PersonType;

typedef enum BookDetailSectionsEnum
{
    BookTitleSection = 0,
    BookWorkersSection,
    BookDetailsSection,
    BookInstanceDetailsSection,
    BookSignatureSection,
    BookAwardSection,
    BookPointSection,
    BookCollectionSection,
    BookDetailSectionCount
} BookDetailSections;

typedef enum BookTitleSectionRowsEnum
{
    BookTitleRow = 0,
    BookTitleSectionRowCount
} BookTitleSectionRows;

typedef enum BookDetailsSectionRowsEnum
{
    BookFormatRow = 0,
    BookEditionRow,
    BookPagesRow,
    BookIsbnRow,
    BookSeriesNameRow,
    BookOriginalPriceRow,
    BookReleaseDateRow,
    BookPublisherRow,
    BookDetailsSectionRowCount
} BookDetailsSectionRows;

typedef enum BookInstanceDetailsSectionRowsEnum
{
    BookBookConditionRow = 0,
    BookJacketConditionRow,
    BookPrintingRow,
    BookPurchaseDateRow,
    BookPricePaidRow,
    BookCurrentValueRow,
    BookLastReadRow,
    BookNumberRow,
    BookPrintRunRow,
    BookBoughtFromRow,
    BookLocationRow,
    BookCommentsRow,
    BookInstanceDetailsSectionRowCount
} BookInstanceDetailsSectionRows;

typedef enum BookDataFieldTagEnum
{
    BookTitleTag = 0,
    BookFormatTag,
    BookEditionTag,
    BookPagesTag,
    BookIsbnTag,
    BookReleaseDateTag,
    BookPurchaseDateTag,
    BookOriginalPriceTag,
    BookPricePaidTag,
    BookCurrentValueTag,
    BookBookConditionTag,
    BookJacketConditionTag,
    BookPrintingTag,
    BookNumberTag,
    BookPrintRunTag,
    BookCommentsTag,
    BookWorkerTag,
    BookPublisherTag,
    BookBoughtFromTag,
    BookSignatureTag,
    BookAwardTag,
    BookPointTag,
    BookCollectionTag,
    BookLastReadTag,
    BookSeriesNameTag,
    BookLocationTag
} BookDataFieldTag;

typedef enum CollectionDetailSectionsEnum
{
    CollectionDataSection = 0,
    CollectionBookSection,
    CollectionDetailSectionCount
} CollectionDetailSections;

typedef enum CollectionDataSectionRowsEnum
{
    CollectionNameRow = 0,
    CollectionDataSectionRowCount
} CollectionDataSectionRows;

typedef enum CollectionDataFieldTagEnum
{
    CollectionNameTag = 0,
    CollectionBookTag
} CollectionDataFieldTag;

typedef enum LookupTypeEnum
{
    LookupTypeEdition = 1,
    LookupTypeFormat,
    LookupTypeCondition,
    LookupTypeCountry,
    LookupTypeState,
    LookupTypeWorker,
    LookupTypeLocation
} LookupType;

typedef enum PersonDetailSectionsEnum
{
    PersonDataSection = 0,
    PersonWorkedSection,
    PersonBooksSignedSection,
    PersonAliasSection,
    PersonAliasOfSection,
    PersonDetailSectionCount
} PersonDetailSections;

typedef enum PersonDataSectionRowsEnum
{
    PersonFirstNameRow = 0,
    PersonMiddleNameRow,
    PersonLastNameRow,
    PersonBornRow,
    PersonDiedRow,
    PersonDataSectionRowCount
} PersonDataSectionRows;

typedef enum PersonDataFieldTagEnum
{
    PersonFirstNameTag = 0,
    PersonMiddleNameTag,
    PersonLastNameTag,
    PersonBornTag,
    PersonDiedTag,
    PersonWorkedTag,
    PersonSignedTag,
    PersonAliasTag,
    PersonAliasOfTag
} PersonDataFieldTag;

typedef enum PointDetailSectionsEnum
{
    PointDataSection = 0,
    PointDetailSectionCount,
} PointDetailSections;

typedef enum PointDataSectionRowsEnum
{
    PointIssueRow = 0,
    PointLocationRow,
    PointDataSectionRowCount,
} PointDataSectionRows;

typedef enum PublisherDetailSectionsEnum
{
    PublisherDataSection = 0,
    PublisherBooksSection,
    PublisherDetailSectionCount
} PublisherDetailSections;

typedef enum PublisherDataSectionRowsEnum
{
    PublisherNameRow = 0,
    PublisherParentRow,
    PublisherStreetRow,
    PublisherStreet1Row,
    PublisherCityRow,
    PublisherStateRow,
    PublisherPostalCodeRow,
    PublisherCountryRow,
    PublisherDataSectionRowCount
} PublisherDataSectionRows;

typedef enum PublisherDataFieldTagEnum
{
    PublisherNameTag = 0,
    PublisherParentTag,
    PublisherStreetTag,
    PublisherStreet1Tag,
    PublisherCityTag,
    PublisherStateTag,
    PublisherPostalCodeTag,
    PublisherCountryTag,
    PublisherBookTag
} PublisherDataFieldTag;

typedef enum SellerDetailSectionsEnum
{
    SellerDataSection = 0,
    SellerBooksSection,
    SellerDetailSectionCount
} SellerDetailSections;

typedef enum SellerDataSectionRowsEnum
{
    SellerNameRow = 0,
    SellerStreetRow,
    SellerStreet1Row,
    SellerCityRow,
    SellerStateRow,
    SellerPostalCodeRow,
    SellerCountryRow,
    SellerEmailRow,
    SellerPhoneRow,
    SellerWebsiteRow,
    SellerDataSectionRowCount
} SellerDataSectionRows;

typedef enum SellerDataFieldTagEnum
{
    SellerNameTag = 0,
    SellerStreetTag,
    SellerStreet1Tag,
    SellerCityTag,
    SellerStateTag,
    SellerPostalCodeTag,
    SellerCountryTag,
    SellerEmailTag,
    SellerPhoneTag,
    SellerWebsiteTag,
    SellerBookTag
} SellerDataFieldTag;

#endif
