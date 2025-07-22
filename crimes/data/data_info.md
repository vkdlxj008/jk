# Data Information

## Source Data Overview
- **Data Name**: Chicago Police Department - Crimes Dataset (District 11 Only)
- **Source**: City of Chicago Data Portal
- **URL**: https://data.cityofchicago.org/Public-Safety/Crimes-2001-to-Present/ijzp-q8t2
- **File Size**: Approximately 1.7GB (original file excluded due to GitHub capacity limitations)
- **Update Cycle**: Daily

## Data Structure

| Column Name | Type | Description | Example |
|-------------|------|-------------|---------|
| ID | Integer | Unique identifier | 13210072 |
| Case Number | String | Case identification number | JG422242 |
| Date | DateTime | Crime occurrence date/time | 08/11/2023 11:00:00 AM |
| Block | String | Block-level address | 0000X S ALBANY AVE |
| IUCR | String | Illinois Uniform Crime Reporting code | 1790 |
| Primary Type | String | Main crime category | MOTOR VEHICLE THEFT |
| Description | String | Detailed crime description | AUTOMOBILE |
| Location Description | String | Type of location | STREET, RESIDENCE |
| Arrest | Boolean | Whether arrest was made | TRUE/FALSE |
| Domestic | Boolean | Domestic violence related | TRUE/FALSE |
| Beat | Integer | Police beat area | 1124 |
| District | Integer | Police district number | 11 |
| Ward | Integer | City council ward | 28 |
| Community Area | Integer | Chicago community area number | 27 |
| FBI Code | String | FBI crime classification code | 26 |
| X Coordinate | Float | Illinois State Plane coordinate X | 1155914 |
| Y Coordinate | Float | Illinois State Plane coordinate Y | 1899709 |
| Year | Integer | Year of occurrence | 2023 |
| Updated On | DateTime | Last data update timestamp | 09/16/2023 03:41:56 PM |
| Latitude | Float | Latitude coordinate | 41.88059439 |
| Longitude | Float | Longitude coordinate | -87.70295942 |
| Location | String | Coordinate pair | (41.880594385, -87.702959421) |

## Data Preprocessing Process
1. Load original CSV file (approximately 118,992K rows from District 11)
2. Convert Date column to proper Date format
3. Aggregate data by day, crime type, and location for storage optimization
4. Save processed data as `daily_crimes_summary.csv`

## Reproduction Method
To reproduce analysis with source data:
1. Download latest data from City of Chicago Data Portal
2. Run `scripts/01_data_preprocessing.R` to generate aggregated data
3. Execute analysis using `scripts/02_analysis.R`

## Important Notes
- **Geographic Scope**: This dataset contains only District 11 (Harrison District) crime data
- **Coverage Area**: West Side Chicago neighborhoods including Austin, Garfield Park area
- Exact addresses masked to block-level for privacy protection
- Cases under investigation may have limited information
- Records without coordinate data excluded from spatial analysis

## Data Limitations
- Analysis represents only one district out of 25 Chicago police districts
- Results cannot be generalized to entire Chicago metropolitan area
- For city-wide analysis, full dataset download required from source
