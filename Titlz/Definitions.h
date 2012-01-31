//
//  Definitions.h
//  Titlz
//
//  Created by David Lains on 1/12/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#ifndef Titlz_Definitions_h
#define Titlz_Definitions_h

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

typedef enum PersonTypeEnum
{
    Author = 0,
    Editor,
    Illustrator,
    Contributor,
    Alias,
    Signature,
} PersonType;

typedef enum BookDetailSectionsEnum
{
    BookDataSection = 0,
    BookAuthorSection,
    BookEditorSection,
    BookIllustratorSection,
    BookContributorSection,
    BookSignatureSection,
    BookAwardSection,
    BookPointSection,
    BookPublisherSection,
    BookBoughtFromSection,
    BookCollectionSection,
    BookDetailSectionCount
} BookDetailSections;

typedef enum BookDataSectionRowsEnum
{
    BookTitleRow = 0,
    BookFormatRow,
    BookEditionRow,
    BookPrintingRow,
    BookIsbnRow,
    BookPagesRow,
    BookReleaseDateRow,
    BookPurchaseDateRow,
    BookOriginalPriceRow,
    BookPricePaidRow,
    BookCurrentValueRow,
    BookBookConditionRow,
    BookJacketConditionRow,
    BookNumberRow,
    BookPrintRunRow,
    BookCommentsRow,
    BookDataSectionRowCount
} BookDataSectionRows;

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

typedef enum LookupTypeEnum
{
    LookupTypeEdition = 1,
    LookupTypeFormat,
    LookupTypeCondition,
    LookupTypeCountry,
    LookupTypeState
} LookupType;

typedef enum PersonDetailSectionsEnum
{
    PersonDataSection = 0,
    PersonAliasSection,
    PersonAliasOfSection,
    PersonAuthoredSection,
    PersonEditedSection,
    PersonIllustratedSection,
    PersonContributedSection,
    PersonBooksSignedSection,
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

#endif
