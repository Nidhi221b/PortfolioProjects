/* 
Cleaning Data Using SLQ
*/

Select * from
PortfolioProject.dbo.NashvilleHousing;

-------------STANDARDIZE SALE DATE FORMAT by removing the time component-------------------------------------
Select SaleDate
from PortfolioProject.dbo.NashvilleHousing;

Select SaleDate,CONVERT(Date,SaleDate) as DateOfSale
from PortfolioProject.dbo.NashvilleHousing;

Alter TABLE NashvilleHousing
add DateOfsale Date;

Update NashvilleHousing
SET DateOfsale=CONVERT(Date,SaleDate);

Select DateOfsale
from NashvilleHousing;

-----------Handling NULL VALUES IN ADDRESS------------------------
Select* from
PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is Null;

Select* from
PortfolioProject.dbo.NashvilleHousing
order by ParcelID;
/* 
two properties having same parcel id has same housing address so we can use this info to fill null values 
*/
Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
  on a.ParcelID=b.ParcelID
  and a.[UniqueID ]!=b.[UniqueID ]
where a.PropertyAddress is Null

Update a
SET PropertyAddress =ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
  on a.ParcelID=b.ParcelID
  and a.[UniqueID ]!=b.[UniqueID ]

---------------Splitting Property address to address and city----------------------------------
Select PropertyAddress
from
PortfolioProject.dbo.NashvilleHousing;

Alter table NashvilleHousing
add address Nvarchar(250),city Nvarchar(250);

Update NashvilleHousing
SET address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1); 

Select address
from
PortfolioProject.dbo.NashvilleHousing;

Update NashvilleHousing
SET city = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)); 

Select city
from
PortfolioProject.dbo.NashvilleHousing;
Select *
from
PortfolioProject.dbo.NashvilleHousing;

---------------Owner address split to adress city and state-------------------------------
SELECT
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing;

Alter table NashvilleHousing
add OwnerAddress1 Nvarchar(100),OwnerCity Nvarchar(50),OwnerState Nvarchar(50);

Update NashvilleHousing
Set OwnerAddress1=PARSENAME(replace(OwnerAddress,',','.'),3),
OwnerCity=PARSENAME(replace(OwnerAddress,',','.'),2),
OwnerState=PARSENAME(replace(OwnerAddress,',','.'),1);

Select * from NashvilleHousing;

---------------------SoldVsVacant column values--------------------------------------------------------
SELECT distinct(SoldAsVacant),COUNT(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2;

/* Let's convert Y to yes and N to No to avoid confusion */
 SELECT SoldAsVacant,
 CASE
 when SoldAsVacant = 'Y' then 'Yes'
 when SoldAsVacant = 'N' then 'No'
 else SoldAsVacant
 END
 from PortfolioProject.dbo.NashvilleHousing;

 update NashvilleHousing
 set SoldAsVacant =
 CASE
 when SoldAsVacant = 'Y' then 'Yes'
 when SoldAsVacant = 'N' then 'No'
 else SoldAsVacant
 END
 from PortfolioProject.dbo.NashvilleHousing;

--------------------------------------------------------------------------------------------
-----Let's remove duplicate data
With RowNumCTE AS(
SELECT * ,
 ROW_NUMBER() Over (
 Partition by ParcelID,
              PropertyAddress,
			  SaleDate,
			  SalePrice,
			  LegalReference
			  Order by
			  UniqueID
			  )row_num
from PortfolioProject.dbo.NashvilleHousing)
DELETE
from RowNumCTE
where row_num>1;

------------------------------------------------------------------------------------------------------
----------DELETE UNUSED COLUMNS----------------------------

Select *
from PortfolioProject.dbo.NashvilleHousing;

/* We have created some new columns from Property address,SaleDate,OwnerAddress 
Leaving these columns useless so we will drop these */

Alter table
PortfolioProject.dbo.NashvilleHousing
drop column PropertyAddress,SaleDate,OwnerAddress;

/* The column Tax district doesnt make much sense to me so i will drop that as well! */

Alter table
PortfolioProject.dbo.NashvilleHousing
drop column TaxDistrict;