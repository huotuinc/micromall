package com.micromall.datacenter.service.good.impl;

import com.micromall.datacenter.bean.agent.MallAgentBean;
import com.micromall.datacenter.bean.goods.MallGoodBean;
import com.micromall.datacenter.dao.good.MallGoodsDao;
import com.micromall.datacenter.service.agent.MallAgentService;
import com.micromall.datacenter.service.good.MallGoodsService;
import com.micromall.datacenter.viewModel.good.GoodPriceViewModel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Administrator on 2015/5/14.
 */
@Service
public class MallGoodsServiceImpl implements MallGoodsService {
    @Autowired
    private MallGoodsDao dao;
    @Autowired
    private MallAgentService agentService;

    @Transactional
    public MallGoodBean save(MallGoodBean bean) {
        return dao.save(bean);
    }

    @Transactional
    public void delete(int goodId) {
        dao.delete(goodId);
    }

    @Transactional(readOnly = true)
    public MallGoodBean findByGoodId(int goodId) {
        MallGoodBean goodBean = dao.findOne(goodId);
        List<GoodPriceViewModel> list = new ArrayList<GoodPriceViewModel>();
        String[] tempInfo = goodBean.getPriceInfo().split(",");
        for (String levelPrice : tempInfo) {
            String[] info = levelPrice.split(":");
            GoodPriceViewModel viewModel = new GoodPriceViewModel();
            viewModel.setLevelId(info[0]);
            viewModel.setLevelName(info[1]);
            viewModel.setPrice(info[2]);
            list.add(viewModel);
        }
        goodBean.setPriceViewModelList(list);
        return goodBean;
    }

    @Transactional(readOnly = true)
    public List<MallGoodBean> findAll(int customerId, String goodName) {
        return dao.findByCustomerIdAndGoodNameContaining(customerId, goodName);
    }

    /**
     * 得到某个代理商等级的价格
     *
     * @param agentLevel
     * @param priceInfo  levelid:price|levelid:price
     * @return
     */
    public double getPriceByAgent(int agentLevel, String priceInfo) {
        String[] tempInfo = priceInfo.split(",");
        for (String levelPrice : tempInfo) {
            String[] info = levelPrice.split(":");
            if (Integer.parseInt(info[0]) == agentLevel) {
                return Double.parseDouble(info[2]);
            }
        }
        return 0;
    }

    /**
     * 得到某个代理商等级商品的价格
     *
     * @param goodList
     * @param agentLevel
     * @return
     */
    public List<MallGoodBean> setAgentPrice(List<MallGoodBean> goodList, int agentLevel) {
        for (MallGoodBean goodBean : goodList) {
            String[] tempInfo = goodBean.getPriceInfo().split(",");
            for (String levelPrice : tempInfo) {
                String[] info = levelPrice.split(":");
                if (Integer.parseInt(info[0]) == agentLevel) {
                    goodBean.setPrice(Double.parseDouble(info[2]));
                }
            }
        }
        return goodList;
    }

    public String findPriceInfo(int goodId) {
        return dao.findPriceInfo(goodId);
    }

    public boolean goodCodeExists(String goodCode, int customerId, int currentGoodId) {
        return dao.goodCodeExists(goodCode, customerId, currentGoodId) > 0 ? true : false;
    }

    public MallGoodBean findByGoodCode(int customerId, String goodCode) {
        return dao.findByCustomerIdAndGoodCode(customerId, goodCode);
    }

    public int countByCustomerId(int customerId) {
        return dao.countByCustomerId(customerId);
    }

    public String getGoodCode(int customerId) {
        String suffix = "000" + (countByCustomerId(customerId) + 1);
        suffix = suffix.substring(suffix.length() - 3, suffix.length());
        return customerId + suffix;
    }

    public List<MallGoodBean> findCheckableGoods(int customerId, int agentId) {
        MallAgentBean agentBean = agentService.findByAgentId(agentId);
        List<MallGoodBean> goodList = this.findAll(customerId, "");
        if ("all".equals(agentBean.getGroups())) {
            return goodList;
        } else {
            String[] groupArray = agentBean.getGroups().substring(1, agentBean.getGroups().length() - 1).split("/|");
            List<MallGoodBean> resultGoodList = new ArrayList<MallGoodBean>();
            for (MallGoodBean goodBean : goodList) {
                if ("all".equals(goodBean.getGroups())) {
                    resultGoodList.add(goodBean);
                } else {
                    boolean index = false;
                    for (String groupId : groupArray) {
                        if (goodBean.getGroups().contains("|" + groupId + "|"))
                            index = true;
                        else {
                            index = false;
                            break;
                        }
                    }
                    if (index) {
                        resultGoodList.add(goodBean);
                    }
                }
            }
            return resultGoodList;
        }
    }
}
