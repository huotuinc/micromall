package com.micromall.datacenter.service.order;

import com.micromall.datacenter.bean.orders.MallOrderBean;
import com.micromall.datacenter.bean.orders.MallOrderItemBean;
import com.micromall.datacenter.viewModel.log.AgentShipmentsViewModel;
import com.micromall.datacenter.viewModel.order.MallOrderSearchViewModel;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;

/**
 * Created by Administrator on 2015/5/14.
 */
public interface MallOrderService {
    MallOrderBean create(MallOrderBean bean, int goodId, int realShipId);

    Page<MallOrderBean> findAll(MallOrderSearchViewModel searchViewModel, int pageIndex, int pageSize, int customerId);

    MallOrderBean findByOrderId(String orderId);

    void updateOrderStatus(String orderId, int orderStatus);

    void confirmShip(MallOrderBean orderBean, String[] proCodes, String logiName, String logiNum);

    void transferOrder(String orderId, int transferTo);

    String createOrderId(int customerId);

    Page<MallOrderBean> findAll(int customerId, int agentId, int pageIndex, int pageSize, int orderType, String orderId);

    int findCountInOrder(int customerId, int agentId);

    /**
     * ��Ʒ��ѯ
     *
     * @param customerId
     * @param snCode
     * @return
     */
    Page<MallOrderItemBean> findBySnCode(int customerId, String snCode, int pageIndex, int pageSize);
}
