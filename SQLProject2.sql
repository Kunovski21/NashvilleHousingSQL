select *
from PortfolioProject2..NashvilleHousing

-- Standardize Date Format

select SaleDateConverted, convert(Date,SaleDate)
from PortfolioProject2..NashvilleHousing

alter table NashVilleHousing
add SaleDateConverted date

update NashvilleHousing
set SaleDateConverted = convert(Date,SaleDate)

-- Populate Property Address Data

select *
from PortfolioProject2..NashvilleHousing
order by ParcelID
--where PropertyAddress is null


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject2..NashvilleHousing a
join PortfolioProject2..NashvilleHousing  b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject2..NashvilleHousing a
join PortfolioProject2..NashvilleHousing  b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from PortfolioProject2..NashvilleHousing
--order by ParcelID
--where PropertyAddress is null

select 
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress)) as Address
from PortfolioProject2..NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress))

select *
from PortfolioProject2..NashvilleHousing

select OwnerAddress
from PortfolioProject2..NashvilleHousing

select 
parsename (replace(OwnerAddress,',','.'),3),
parsename (replace(OwnerAddress,',','.'),2),
parsename (replace(OwnerAddress,',','.'),1)
from PortfolioProject2..NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = parsename (replace(OwnerAddress,',','.'),3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255)

update NashvilleHousing
set OwnerSplitCity = parsename (replace(OwnerAddress,',','.'),2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255)

update NashvilleHousing
set OwnerSplitState = parsename (replace(OwnerAddress,',','.'),1)


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject2..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from PortfolioProject2..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from PortfolioProject2..NashvilleHousing

-- Remove Duplicates

with RowNumCTE as (
select *,
	row_number() over (
	partition by ParcelId,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by 
					UniqueID
					) row_num
from PortfolioProject2..NashvilleHousing
)
delete
from RowNumCTE
where row_num > 1



-- Delete Unused Columns

select *
from PortfolioProject2..NashvilleHousing

alter table PortfolioProject2..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table PortfolioProject2..NashvilleHousing
drop column SaleDate