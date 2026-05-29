create SCHEMA swiggy_project

select * from swiggy_project.dim_date
select count(*) from swiggy_project.dim_date

select * from swiggy_project.dim_dish
select count(*) from swiggy_project.dim_dish

select * from swiggy_project.dim_location
select count(*) from swiggy_project.dim_location

select * from swiggy_project.dim_restaurant
select count(*) from swiggy_project.dim_restaurant

select * from swiggy_project.fact_orders
select count(*) from swiggy_project.fact_orders

alter table swiggy_project.dim_date
add order_date_new date 

update swiggy_project.dim_date
set order_date_new=TRY_CONVERT(date,order_date,5)

select * from swiggy_project.dim_date
where order_date_new is null



--state revenue 
select dl.state,count(fo.order_id) as total_orders,
round(sum(fo.price),0) as total_revenue,
round(avg(fo.price),0) as avg_order_value,
count(distinct fo.restaurant_id) as num_restaurants,
rank() over (order by sum(fo.price) desc ) as revenue_rank
from swiggy_project.fact_orders fo
join swiggy_project.dim_location dl
on fo.location_id=dl.location_id
group by dl. state 
order by total_revenue desc

--top 10 restaurants by revenue
select dr.restaurant_name,count(fo.order_id) as total_orders,
ROUND(sum(fo.price),0) as total_revenue,
round(avg(fo.price),0) as avg_order_value,
round(avg(fo.rating),2) as avg_rating,
round(sum(fo.price)* 100.0/sum(sum(fo.price)) over(),2) as revenue_share_pct
from swiggy_project.fact_orders fo
join swiggy_project.dim_restaurant dr
on fo.restaurant_id=dr.restaurant_id
group by dr.restaurant_name
order by total_revenue DESC

 --avg order value by food category
select dd.category,count(fo.order_id) as total_orders,
round(sum(fo.price),0) as total_revenue,
round(avg(fo.price),0) as avg_order_value,
round(min(fo.price),0) as min_price,
round(max(price),0) as max_price,
round(avg(fo.rating),2) as avg_rating
from swiggy_project.fact_orders fo 
join swiggy_project.dim_dish dd
on fo.order_id=dd.dish_id
group by dd.category
having count(fo.order_id)>=100
order by avg_order_value desc
 --city level revenue
select top 15 dl.state,dl.city,count(fo.order_id) as total_orders,
round(sum(fo.price),0) as total_revenue,
round(avg(fo.price),0) as avg_order_value,
count(distinct fo.restaurant_id) as restaurants,
rank() over (order by sum(fo.price) desc) as city_rank
from swiggy_project.fact_orders fo 
join swiggy_project.dim_location dl
on fo.location_id=dl.location_id
group by dl.state,dl.city
order by total_revenue desc  

--high value vs low value order split
--Business Question: What share of orders and revenue come from budget vs premium customers?

select case when price<200 then 'low_value (<Rs 200)'
when price between 200 and 500 then 'mid_value (Rs 200-500)'
when price>500 then 'High value (>Rs 500)'
end as order_Segemnt,
count(order_id) as total_orders,
round(sum(price),0) as total_revenue,
round(avg(price),0) as avg_price,
round(avg(rating),2) as avg_rating,
round(count(order_id)*100.0/sum(count(order_id)) over (),1) as order_share,
round(sum(price)*100.0 / sum(sum(price)) over (),1) as revenue_share
from  swiggy_project.fact_orders
where price between 10 and 3000
group by 
case when price<200 then 'low_value (<Rs 200)'
when price between 200 and 500 then 'mid_value (Rs 200-500)'
when price>500 then 'High value (>Rs 500)'
end 
order by avg_price

--monthly revenue trend with mom growth
select month(dd.order_date_new) as month ,
datename(month,dd.order_date_new) as month_name,
count(fo.order_id) as total_orders,
round(sum(fo.price),0) as total_revenue,
round(avg(fo.price),0) as avg_order_value,
round((sum(fo.price)-lag(sum(fo.price))over (order by month(dd.order_date_new)))/
lag(sum(fo.price)) over (order by month(dd.order_date_new))*100,1)
as mom_growth_pct
from swiggy_project.fact_orders fo
join swiggy_project.dim_date dd 
on fo.date_id=dd.date_id
group by month(dd.order_date_new),datename(month,dd.order_date_new)
order by month

--price vs rating
with price_segments as (
select order_id,price,rating,rating_count,
case when price<200 then '1. Budget(<Rs 200)'
when price between 200 and 500 then '2. Mid (Rs 200-500)'
when price between 500 and 1000 then '3. Premium (Rs 500-1K)'
else '4. Luxury (Rs 1K+)'
end as price_segment
from swiggy_project.fact_orders
where price between 10 and 3000)
select price_segment,count(order_id) as total_orders,
round(avg(price),0) as avg_price,
round(avg(rating),3) as avg_rating,
round(avg(rating_count),1) as avg_review_count,
round(sum(case when rating_count>0 then 1.0
 else 0 end)/count(order_id)*100,1) as pct_with_reviews
 from price_segments
 group by price_segment
 order by price_segment

 --rating distrubtuion
select rating,count(order_id) as order_count,
round(count(order_id)*100.0/sum(count(order_id)) over(),2)
as pct_of_total
from swiggy_project.fact_orders
group by rating
order by order_count desc

--restaurant density by state
select dl.state,count(distinct fo.restaurant_id) as num_res,
count(fo.order_id) as total_orders,
round(sum(fo.price),0) as total_revenue,
round(sum(fo.price)/count(distinct fo.restaurant_id),0) as revenue_per_res,
round(count(fo.order_id)*1.0/count(distinct fo.restaurant_id),0) as order_per_res
from swiggy_project.fact_orders fo
join swiggy_project.dim_location dl
on fo.location_id=dl.location_id
group by dl.state 
order by num_res 

--state revenue 
select dl.state,count(fo.order_id) as total_orders,
round(sum(fo.price),0) as total_revenue,
round(avg(fo.price),0) as avg_order_value,
count(distinct fo.restaurant_id) as num_restaurants,
rank() over (order by sum(fo.price) desc ) as revenue_rank
from swiggy_project.fact_orders fo
join swiggy_project.dim_location dl
on fo.location_id=dl.location_id
group by dl. state 
order by total_revenue desc

--top 10 restaurants by revenue
select dr.restaurant_name,count(fo.order_id) as total_orders,
ROUND(sum(fo.price),0) as total_revenue,
round(avg(fo.price),0) as avg_order_value,
round(avg(fo.rating),2) as avg_rating,
round(sum(fo.price)* 100.0/sum(sum(fo.price)) over(),2) as revenue_share_pct
from swiggy_project.fact_orders fo
join swiggy_project.dim_restaurant dr
on fo.restaurant_id=dr.restaurant_id
group by dr.restaurant_name
order by total_revenue DESC

