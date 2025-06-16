-- Cleaning Data in SQL Queries
Select * from covid.nashvillehousing;

-- ----------------- Date Format
Select SaleDate, convert(SaleDate, date) from nashvillehousing;

Alter table nashvillehousing
add column convertdate varchar(50);

Update nashvillehousing
set convertdate = SaleDate;

Update nashvillehousing
set convertdate = STR_TO_DATE(convertdate,  '%M %d, %Y');

Update nashvillehousing
set SaleDate = convertdate;

Alter table nashvillehousing
modify column SaleDate date;

Select SaleDate, convertdate from covid.nashvillehousing;

Alter table nashvillehousing
drop column convertdate;
-- Populate Property Address data
-- Select * 
-- from covid.nashvillehousing
-- order by parcelID
-- -- where PropertyAddress is null or PropertyAddress='';
-- Select PropertyAddress
-- from covid.nashvillehousing
-- where PropertyAddress='1';
-- update covid.nashvillehousing
-- set PropertyAddress=owneraddress
-- where PropertyAddress='1';
-- UPDATE covid.nashvillehousing
-- SET PropertyAddress = REPLACE(PropertyAddress, ', TN', '');


-- ----------Populate Property Address data--------------------
Select a.parcelID, a.PropertyAddress, b.parcelID, b.PropertyAddress, ifnull(nullif(a.PropertyAddress,''), b.PropertyAddress)
from covid.nashvillehousing a
join covid.nashvillehousing b
	on a.parcelID=b.parcelID
    and a.uniqueID <> b.uniqueID
where a.PropertyAddress is null or a.PropertyAddress='';
-- Update SQL: update [table_1] -> join [table_2] on.... -> set... where
update covid.nashvillehousing a
join covid.nashvillehousing b
	on a.parcelID=b.parcelID
    and a.uniqueID <> b.uniqueID
set a.PropertyAddress = (ifnull(nullif(a.PropertyAddress,''), b.PropertyAddress))
where a.PropertyAddress is null or a.PropertyAddress='';

Select *
from covid.nashvillehousing;

-- --------Breaking out Address into individual column (Address, City, State)
Select PropertyAddress
from covid.nashvillehousing;

Select PropertyAddress, substring_index(PropertyAddress, ' ',1) as Number,
						substring(PropertyAddress,1, LOCATE(',',PropertyAddress)-1) as Address, 
						substring(PropertyAddress,LOCATE(',',PropertyAddress)+1, length(PropertyAddress)) as City
from covid.nashvillehousing;

alter table covid.nashvillehousing
add column PropertySplitAddress varchar(50);
update covid.nashvillehousing
set PropertySplitAddress = substring(PropertyAddress,1, LOCATE(',',PropertyAddress)-1);

alter table covid.nashvillehousing
add column PropertySplitCity varchar(50);
update covid.nashvillehousing
set PropertySplitCity = substring(PropertyAddress,LOCATE(',',PropertyAddress)+1, length(PropertyAddress));

-- alter table covid.nashvillehousing
-- drop column PropertySplitCity;
-- alter table covid.nashvillehousing
-- drop column PropertySplitAddress;

select PropertyAddress, PropertySplitAddress, PropertySplitCity
from covid.nashvillehousing;

-- ---------- Processing OwnerAddress split
Select OwnerAddress
from covid.nashvillehousing;

Select	OwnerAddress,
        SUBSTRING_INDEX(OwnerAddress,',', 1) as SplitAddress,
        SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',', 2),',',-1) as SplitCity,
        SUBSTRING_INDEX(OwnerAddress,',', -1) as TNstring
from covid.nashvillehousing;
-- add column for OwnerAdress
alter table covid.nashvillehousing
add column OwnerSplitAddress varchar(50);
update covid.nashvillehousing
set OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress,',', 1);

alter table covid.nashvillehousing
add column OwnerSplitCity varchar(50);
update covid.nashvillehousing
set OwnerSplitCity =  SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',', 2),',',-1);

alter table covid.nashvillehousing
add column OwnerSplitState varchar(50);
update covid.nashvillehousing
set OwnerSplitState =  SUBSTRING_INDEX(OwnerAddress,',', -1);

-- alter table covid.nashvillehousing
-- drop column OwnerSplitAddress;
-- alter table covid.nashvillehousing
-- drop column OwnerSplitCity;
-- alter table covid.nashvillehousing
-- drop column OwnerSplitState;

select OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from covid.nashvillehousing;

-- Change Y and N to Yes and No in "Sold in Vacant" field
Select SoldAsVacant, count(SoldAsVacant)
from covid.nashvillehousing
group by SoldAsVacant;

-- update covid.nashvillehousing
-- set SoldAsVacant='Yes'
-- where SoldAsVacant='Y';
-- update covid.nashvillehousing
-- set SoldAsVacant='No'
-- where SoldAsVacant='N';

Select SoldAsVacant,
	case
		when SoldAsVacant='Y' then 'Yes'
        when SoldAsVacant='N' then 'No'
        else SoldAsVacant
	end as SoldAsVacantChange
from covid.nashvillehousing
where SoldAsVacant='N' or SoldAsVacant='Y';

update covid.nashvillehousing
Set SoldAsVacant=
	case
		when SoldAsVacant='Y' then 'Yes'
        when SoldAsVacant='N' then 'No'
        else SoldAsVacant
	end;

-- -----------------Removing Duplicates
with RownumCTE as(
Select *,
	row_number() over( 
    partition by ParcelID,
				PropertyAddress,
				Saleprice,
                saledate,
                LegalReference
	order by uniqueID
			) as rownum
from covid.nashvillehousing
-- order by ParcelID
)
delete nas
from covid.nashvillehousing nas
join RownumCTE ro on nas.uniqueID=ro.uniqueID
where ro.rownum>1;
-- count duplicates
Select * 
from RownumCTE
where rownum=1 and rownum>1;
Select rownum, count(rownum)
from RownumCTE
group by rownum;

--  Drop column not use
select *
from covid.nashvillehousing;

alter table covid.nashvillehousing
drop column PropertyAddress,
drop column OwnerAddress;

