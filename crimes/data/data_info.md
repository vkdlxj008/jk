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

## Data Processing Pipeline

### Stage 1: Initial Aggregation (`01_data_preprocessing.R`)
1. Load original CSV file (approximately 118,992K rows from District 11)
2. Convert Date column to proper Date format using `mdy_hms()`
3. Group by Day, Year, Primary Type, and Location Description
4. Count incidents per group
5. Save as `daily_crimes_summary.csv`

### Stage 2: Summary Generation (`01b_generate_summaries.R`)
From the daily aggregated data, generate multiple summary files:

#### Generated Files:
- **`daily_crimes_summary.csv`** - Daily aggregated crime data (primary dataset)
- **`monthly_summary.csv`** - Monthly aggregations by crime type and location
- **`crime_types_summary.csv`** - Summary statistics by crime type
- **`locations_summary.csv`** - Summary statistics by location type
- **`cleaned_data.rds`** - R data structure containing all processed datasets

#### Additional Reference Files:
- `monthly_totals.csv` - Monthly overall statistics
- `crime_yearly_trends.csv` - Annual trends by crime type
- `location_yearly_trends.csv` - Annual trends by location type

## File Descriptions

### Primary Analysis Files
- **`daily_crimes_summary.csv`**: Base aggregated dataset with daily crime counts by type and location
- **`monthly_summary.csv`**: Monthly aggregations with statistics like total crimes, days with crime, and daily averages
- **`crime_types_summary.csv`**: Comprehensive statistics for each crime type including totals, averages, date ranges, and most common locations
- **`locations_summary.csv`**: Comprehensive statistics for each location type including totals, averages, date ranges, and most common crime types

### Support Files
- **`cleaned_data.rds`**: R binary format containing all datasets plus metadata
- Additional CSV files for yearly trend analysis

## Reproduction Method
To reproduce analysis with source data:
1. Download latest data from City of Chicago Data Portal
2. Filter for District 11 data only
3. Run `scripts/01_data_preprocessing.R` to generate `daily_crimes_summary.csv`
4. Run `scripts/01b_generate_summaries.R` to create all summary files
5. Execute analysis using `scripts/02_analysis.R`

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
- Data aggregated to daily level may mask intra-day patterns
