-- issue/honor no locks and be the deadlock victim if needed
set transaction isolation level read uncommitted
set deadlock_priority -10
set nocount on

-- get sql data
select * from table