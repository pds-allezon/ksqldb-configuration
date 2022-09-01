CREATE STREAM userTags (
    time VARCHAR,
    cookie VARCHAR,
    country VARCHAR,
    device VARCHAR,
    action VARCHAR,
    origin VARCHAR,
    productInfo STRUCT<
        productId VARCHAR,
        brandId VARCHAR,
        categoryId VARCHAR,
        price INT
    >
)
    WITH (kafka_topic='user-tags', format='json', partitions=1);

CREATE TABLE aggregates_origin_brandId_categoryId AS
    SELECT
        SUBSTRING(time, 1, 16) AS bucket,
        action,
        origin,
        productInfo->brandId AS brandId,
        productInfo->categoryId AS categoryId,
        SUM(CAST(productInfo->price AS BIGINT)) AS sumPrice,
        COUNT(*) AS count
    FROM userTags
    GROUP BY SUBSTRING(time, 1, 16), action, origin, productInfo->brandId, productInfo->categoryId;
CREATE TABLE aggregates_origin AS
    SELECT
        bucket,
        action,
        origin,
        SUM(sumPrice) as sumPrice,
        SUM(count) as count
    FROM aggregates_origin_brandId_categoryId
    GROUP BY bucket, action, origin;
CREATE TABLE aggregates_brandId AS
    SELECT
        bucket,
        action,
        brandId,
        SUM(sumPrice) as sumPrice,
        SUM(count) as count
    FROM aggregates_origin_brandId_categoryId
    GROUP BY bucket, action, brandId;
CREATE TABLE aggregates_categoryId AS
    SELECT
        bucket,
        action,
        categoryId,
        SUM(sumPrice) as sumPrice,
        SUM(count) as count
    FROM aggregates_origin_brandId_categoryId
    GROUP BY bucket, action, categoryId;
CREATE TABLE aggregates_origin_brandId AS
    SELECT
        bucket,
        action,
        origin,
        brandId,
        SUM(sumPrice) as sumPrice,
        SUM(count) as count
    FROM aggregates_origin_brandId_categoryId
    GROUP BY bucket, action, origin, brandId;
CREATE TABLE aggregates_origin_categoryId AS
    SELECT
        bucket,
        action,
        origin,
        categoryId,
        SUM(sumPrice) as sumPrice,
        SUM(count) as count
    FROM aggregates_origin_brandId_categoryId
    GROUP BY bucket, action, origin, categoryId;
CREATE TABLE aggregates_brandId_categoryId AS
    SELECT
        bucket,
        action,
        brandId,
        categoryId,
        SUM(sumPrice) as sumPrice,
        SUM(count) as count
    FROM aggregates_origin_brandId_categoryId
    GROUP BY bucket, action, brandId, categoryId;
CREATE TABLE aggregates AS
    SELECT
        bucket,
        action,
        SUM(sumPrice) as sumPrice,
        SUM(count) as count
    FROM aggregates_origin_brandId_categoryId
    GROUP BY bucket, action;