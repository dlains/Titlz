//
//  Definitions.h
//  Titlz
//
//  Created by David Lains on 1/12/12.
//  Copyright (c) 2012 Dagger Lake Software. All rights reserved.
//

#ifndef Titlz_Definitions_h
#define Titlz_Definitions_h

typedef enum PersonTypeEnum
{
    Author = 0,
    Editor,
    Illustrator,
    Contributor,
    Alias,
} PersonType;

typedef enum TitleDetailSectionsEnum
{
    TitleNameSection = 0,
    TitleEditionSection,
    TitleAuthorSection,
    TitleEditorSection,
    TitleIllustratorSection,
    TitleContributorSection,
    TitleBookSection,
    TitleCollectionSection,
    TitleDetailSectionCount
} TitleDetailSections;

typedef enum PersonDetailSectionsEnum
{
    PersonDataSection = 0,
    PersonAliasSection,
    PersonAliasOfSection,
    PersonAuthoredSection,
    PersonEditedSection,
    PersonIllustratedSection,
    PersonContributedSection,
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

typedef enum EditionDetailSectionsEnum
{
    EditionDataSection = 0,
    EditionPublisherSection,
    EditionPointsSection,
    EditionBooksSection,
    EditionDetailSectionCount
} EditionDetailSections;

typedef enum EditionDataSectionRowsEnum
{
    EditionNameRow = 0,
    EditionFormatRow,
    EditionIsbnRow,
    EditionPagesRow,
    EditionPrintRunRow,
    EditionReleaseDateRow,
    EditionDataSectionRowCount
} EditionDataSectionRows;

typedef enum PublisherDetailSectionsEnum
{
    PublisherDataSection = 0,
    PublisherEditionsSection,
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

#endif
