-- Active: 1770914995765@@127.0.0.1@3306
CREATE OR REPLACE TABLE tweets AS
SELECT *
FROM read_json_auto('/home/tkharin/data_eng/DataEngineering/Assignments/archive/farmers-protest-tweets-2021-03-5.json', union_by_name=true, sample_size=200000);

SELECT * 
FROM tweets
LIMIT 100;

-- Basic table (to data type and some json paresed)
CREATE OR REPLACE TABLE tweets_parsed AS
SELECT 
    id::BIGINT as tweet_id,
    TRY_STRPTIME(date, '%Y-%m-%dT%H:%M:%S%z') AS tweet_ts,
    TRY_STRPTIME(date, '%Y-%m-%dT%H:%M:%S%z')::DATE  AS tweet_date,
    content,
    renderedContent  AS rendered_content,
    lang AS tweet_language,
    url,
    replyCount AS reply_count,
    retweetCount AS retweet_count,
    likeCount AS like_count,
    quoteCount AS quote_count,
    conversationId AS conversation_id,
    source,
    sourceUrl AS source_url,
    sourceLabel AS source_label,
    quotedTweet.id::BIGINT AS quoted_tweet_id,
    quotedTweet.user.username::VARCHAR AS quoted_tweet_user_username,
    quotedTweet.user.id::BIGINT AS quoted_tweet_user_id,
    user.username::VARCHAR AS user_username,
    user.displayname::VARCHAR AS user_displayname,
    user.id::BIGINT AS user_id,
FROM tweets;

-- mentionedUsers nested fields

--{'username': amaanbali, 'displayname': Amaan, 'id': 70364936, 'description': NULL, 'rawDescription': NULL, 'descriptionUrls': NULL, 'verified': NULL, 'created': NULL, 'followersCount': NULL, 'friendsCount': NULL, 'statusesCount': NULL, 'favouritesCount': NULL, 'listedCount': NULL, 'mediaCount': NULL, 'location': NULL, 'protected': NULL, 'linkUrl': NULL, 'linkTcourl': NULL, 'profileImageUrl': NULL, 'profileBannerUrl': NULL, 'url': 'https://twitter.com/amaanbali'}

CREATE OR REPLACE TABLE tweet_mentions AS
SELECT t.id::BIGINT as tweet_id,
    m.mentionedUserUnest.username::VARCHAR as mentioned_username,
    m.mentionedUserUnest.id::BIGINT as mentioned_user_id,    
    m.mentionedUserUnest.displayname::VARCHAR as mentioned_user_displayname,
    m.mentionedUserUnest.url::VARCHAR as mention_user_url
FROM tweets t, UNNEST(mentionedUsers) as m(mentionedUserUnest);

 
SELECT mentionedUserUnest.*
FROM tweets t, UNNEST(t.mentionedUsers) AS m(mentionedUserUnest)
LIMIT 100;


-- media
--[{'previewUrl': 'https://pbs.twimg.com/media/ExspGifU8AI27LX?format=jpg&name=small', 'fullUrl': 'https://pbs.twimg.com/media/ExspGifU8AI27LX?format=jpg&name=large', 'type': photo, 'thumbnailUrl': NULL, 'variants': NULL, 'duration': NULL}]


CREATE OR REPLACE TABLE tweet_media AS
SELECT t.id::BIGINT as tweet_id,
    m.mediaUnest.previewUrl as media_preview_url,
    m.mediaUnest.fullUrl as media_full_url,
    m.mediaUnest.type as media_type,
    m.mediaUnest.thumbnailUrl as media_thumbnail_url,
    m.mediaUnest.duration as media_duration 
FROM tweets t, UNNEST(media) as m(mediaUnest);

SELECT DISTINCT m.mediaUnest.type AS media_type
FROM tweets t
CROSS JOIN UNNEST(t.media) AS m(mediaUnest);

-- video from mediaUnest (media_variants) if media_type is videdo than media_variants need to be unnested 

--[{'contentType': video/mp4, 'url': 'https://video.twimg.com/ext_tw_video/1372613445175050247/pu/vid/480x600/o8yAQAnJ8w3iVq01.mp4?tag=12', 'bitrate': 950000}, {'contentType': application/x-mpegURL, 'url': 'https://video.twimg.com/ext_tw_video/1372613445175050247/pu/pl/y6HQO5740_AhZenJ.m3u8?tag=12', 'bitrate': NULL}, {'contentType': video/mp4, 'url': 'https://video.twimg.com/ext_tw_video/1372613445175050247/pu/vid/640x800/nKqRWL1TmTA7iiFh.mp4?tag=12', 'bitrate': 2176000}, {'contentType': video/mp4, 'url': 'https://video.twimg.com/ext_tw_video/1372613445175050247/pu/vid/320x400/7nseZ_DXpSNi-6I3.mp4?tag=12', 'bitrate': 632000}]

CREATE OR REPLACE TABLE tweet_media_variants AS
SELECT
  t.id AS tweet_id,
  m.mediaUnest.type AS media_type,
  v.variant.contentType AS variant_content_type,
  v.variant.url AS variant_url,
  v.variant.bitrate AS variant_bitrate
FROM tweets t,
UNNEST(t.media) AS m(mediaUnest),
UNNEST(m.mediaUnest.variants) AS v(variant)
WHERE m.mediaUnest.type IN ('video', 'gif');

-- user tweeted from

--{'username': ShashiRajbhar6, 'displayname': Shashi Rajbhar, 'id': 1015969769760096256, 'description': 'Satya presan 🤔ho Sakta but prajit💪 nhi
--jhuth se samjhauta kbhi nhi
--Jai Shree Ram 🕉 🙏🕉 followed by hon\'ble @ArunrajbharSbsp', 'rawDescription': 'Satya presan 🤔ho Sakta but prajit💪 nhi
--jhuth se samjhauta kbhi nhi
--Jai Shree Ram 🕉 🙏🕉 followed by hon\'ble @ArunrajbharSbsp', 'descriptionUrls': [], 'verified': false, 'created': '2018-07-08T14:44:03+00:00', 'followersCount': 1788, 'friendsCount': 1576, 'statusesCount': 14396, 'favouritesCount': 26071, 'listedCount': 1, 'mediaCount': 254, 'location': 'Azm Uttar Pradesh, India', 'protected': false, 'linkUrl': NULL, 'linkTcourl': NULL, 'profileImageUrl': 'https://pbs.twimg.com/profile_images/1354331299868237825/eDzdhZTD_normal.jpg', 'profileBannerUrl': 'https://pbs.twimg.com/profile_banners/1015969769760096256/1613727783', 'url': 'https://twitter.com/ShashiRajbhar6'}

CREATE OR REPLACE TABLE tweet_user AS
SELECT t.id AS tweet_id,
    t.user.username AS user_username,
    t.user.displayname AS user_displayname,
    t.user.id AS user_id,
    t.user.description AS user_description,
    t.user.verified AS user_verified,
    TRY_STRPTIME(t.user.created, '%Y-%m-%dT%H:%M:%S%z') AS user_created_ts,
    TRY_STRPTIME(t.user.created, '%Y-%m-%dT%H:%M:%S%z')::DATE  AS user_created_date,
    t.user.followersCount AS user_followers_count,
    t.user.friendsCount AS user_friends_count,
    t.user.statusesCount AS user_statuses_count,
    t.user.favouritesCount AS user_favourites_count,
    t.user.listedCount AS user_listed_count,
    t.user.mediaCount AS user_media_count,
    t.user.location AS user_location,
    t.user.protected AS user_protected,
    t.user.linkUrl AS user_link_url,
    t.user.linkTcourl AS user_link_tcourl,
    t.user.profileImageUrl AS user_profile_image_url,
    t.user.profileBannerUrl AS user_profile_banner_url,
    t.user.url AS user_url
FROM tweets t;


-- Top-3 users by tweet count per day
WITH user_daily_tweets AS (
    SELECT tweet_date, user_id, user_username, COUNT(*) AS tweet_count
    FROM tweets_parsed
    GROUP BY 1, 2, 3
),
ranked AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY tweet_date ORDER BY tweet_count DESC) AS rn
  FROM user_daily_tweets
)
SELECT tweet_date, user_id, user_username, tweet_count
FROM ranked
WHERE rn <= 3
ORDER BY tweet_date ASC, tweet_count DESC;


-- Day-over-day change in tweet volume (як змінювався обсяг твітів відносно попереднього дня)

WITH daily_volume AS (
    SELECT tweet_date, COUNT(*) AS tweet_count
    FROM tweets_parsed
    GROUP BY 1
),
prev_lag AS (
    SELECT tweet_date, tweet_count,
        LAG(tweet_count) OVER (ORDER BY tweet_date) AS prev_day_count
    FROM daily_volume
)
SELECT tweet_date, tweet_count, prev_day_count,
      tweet_count - prev_day_count AS abs_change
FROM prev_lag
ORDER BY tweet_date;


--  tweets volume per day
WITH daily_volume AS (
    SELECT tweet_date, COUNT(*) AS tweet_count
    FROM tweets_parsed
    GROUP BY 1
)
SELECT *
FROM daily_volume;