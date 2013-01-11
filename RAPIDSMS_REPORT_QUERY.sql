select sent.at_location as dp_location,sent.from_location as sc
,sum(sent.quantity) as sent_to_dp_qty, sum(recv.quantity) as recv_qty_dp, sum(dist.quantity) as dp_dist_qty 
from sent_bednets_report sent 
inner join received_bednets_report recv on sent.at_location=recv.at_location
inner join distributed_bednets_report dist on dist.at_location=recv.at_location
group by sc, dp_location
