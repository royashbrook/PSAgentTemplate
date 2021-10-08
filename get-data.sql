-- issue/honor no locks and be the deadlock victim if needed
set transaction isolation level read uncommitted
set deadlock_priority -10
set nocount on

-- get sql data
select * from table

-- do this, not that...

-- do this,
  -- cast(SomeDateTimeField as date) = getdate()
-- not that...
  -- datediff(day, SomeDateTimeField, getdate()) = 0
  -- in reports against a small datedim temp table, usually reduces query cost. ex 10 to 3
  
-- do this,
  -- format(SomeDateTimeField, 'yyyy-MM-ddTHH:mm:sszzz')
-- not that...
  -- SomeDateTimeField
  -- when returned data may end up in json and we want the utc with offset from server
  -- other ways around this, but this is normally quickest and easiest way with these agents

